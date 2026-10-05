"""Vehicle Service Centre: Tkinter UI for Devika's existing MySQL schema."""
import tkinter as tk
from tkinter import ttk, messagebox
from datetime import date, datetime
from decimal import Decimal, InvalidOperation

TABLES = ('CUSTOMER', 'VEHICLE', 'SERVICE_BOOKING', 'JOB_CARD', 'TASK',
          'MECHANIC', 'ASSIGNMENT', 'INSPECTION', 'SPARE_PART', 'PART_USAGE',
          'INVOICE', 'PAYMENT')
CHOICES = {'Status': ('Booked', 'In Progress', 'Completed', 'Cancelled'),
           'Job_Status': ('Open', 'In Progress', 'Completed', 'Cancelled'),
           'Payment_Mode': ('Cash', 'Card', 'UPI', 'Online')}


def convert(value, column):
    """Validate input before passing values separately to parameterized SQL."""
    value = value.strip()
    if not value:
        if column['Null'] == 'YES':
            return None
        raise ValueError(f"{column['Field']} is required.")
    name, kind = column['Field'], column['Type'].lower()
    if kind.startswith('int'):
        result = int(value)
        if (name.endswith('_ID') or name == 'Quantity') and result <= 0:
            raise ValueError(f'{name} must be greater than zero.')
        if name == 'Stock_Quantity' and result < 0:
            raise ValueError('Stock quantity cannot be negative.')
        return result
    if kind.startswith('decimal'):
        result = Decimal(value)
        if not result.is_finite() or result < 0:
            raise ValueError(f'{name} must be a finite, nonnegative number.')
        if name == 'Amount' and result == 0:
            raise ValueError('Payment amount must be greater than zero.')
        precision, scale = map(int, kind[kind.index('(')+1:kind.index(')')].split(','))
        if result != result.quantize(Decimal(1).scaleb(-scale)) or result >= Decimal(10) ** (precision-scale):
            raise ValueError(f'{name} must fit {kind}.')
        return result
    if kind == 'date':
        return date.fromisoformat(value)
    if kind.startswith('datetime'):
        return datetime.strptime(value, '%Y-%m-%d %H:%M:%S')
    if kind.startswith('varchar') and len(value) > int(kind.split('(')[1].split(')')[0]):
        raise ValueError(f'{name} is too long.')
    if name in CHOICES and value not in CHOICES[name]:
        raise ValueError(f'Choose a valid {name}.')
    return value


class App:
    def __init__(self, root):
        self.root = root
        self.connection = None
        self.columns = []
        self.inputs = {}
        self.table = tk.StringVar(value='CUSTOMER')
        root.title('Vehicle Service Centre | Devika - DBMS Project')
        root.geometry('1180x740')
        root.minsize(900, 620)
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TButton', padding=7)
        style.configure('Treeview', rowheight=28)
        style.configure('Title.TLabel', font=('Segoe UI', 20, 'bold'))
        style.configure('Treeview.Heading', font=('Segoe UI', 10, 'bold'))
        root.protocol('WM_DELETE_WINDOW', self.close)
        self.login()

    def clear(self):
        for child in self.root.winfo_children():
            child.destroy()

    def login(self):
        self.clear()
        box = ttk.Frame(self.root, padding=35)
        box.pack(expand=True)
        ttk.Label(box, text='Vehicle Service Centre', style='Title.TLabel').grid(row=0, columnspan=2, pady=12)
        ttk.Label(box, text='Connect to your existing MySQL database').grid(row=1, columnspan=2, pady=10)
        self.settings = {}
        for row, (label, default) in enumerate((('Host', 'localhost'), ('Port', '3306'),
                  ('User', 'root'), ('Password', ''), ('Database', 'VehicleServiceCentre')), 2):
            ttk.Label(box, text=label).grid(row=row, column=0, sticky='w', padx=10, pady=8)
            var = tk.StringVar(value=default)
            entry = ttk.Entry(box, textvariable=var, width=35, show='*' if label == 'Password' else '')
            entry.grid(row=row, column=1, pady=8)
            self.settings[label] = var
        ttk.Button(box, text='Connect', command=self.connect).grid(row=7, columnspan=2, pady=18)
        ttk.Label(box, text='Your password is used only for this connection; it is not saved.').grid(row=8, columnspan=2)

    def connect(self):
        try:
            import mysql.connector
            settings = {k: v.get() for k, v in self.settings.items()}
            connection = mysql.connector.connect(host=settings['Host'], port=int(settings['Port']),
                user=settings['User'], password=settings['Password'], database=settings['Database'],
                connection_timeout=5, autocommit=True)
            try:
                cursor = connection.cursor()
                cursor.execute('SHOW TABLES')
                available = {row[0].upper() for row in cursor.fetchall()}
                cursor.close()
                missing = set(TABLES) - available
                if missing:
                    raise ValueError('Missing tables: ' + ', '.join(sorted(missing)))
            except Exception:
                connection.close()
                raise
            self.connection = connection
            self.settings['Password'].set('')
            self.build()
        except Exception as error:
            self.error(error)

    def error(self, error):
        code = getattr(error, 'errno', None)
        text = {1062: 'This ID or another unique value already exists. Use a new value.',
                1451: 'Other records reference this record. Delete its dependent records first, or use a new unlinked test record.',
                1452: 'The selected parent record does not exist. Refresh and select an existing ID.',
                1045: 'MySQL rejected the username or password. Use your MySQL login details.',
                1049: 'Database not found. Check the database name.',
                2003: 'Cannot reach MySQL. Check that the MySQL service is running and verify host and port.'}.get(code, str(error))
        messagebox.showerror('Operation could not be completed', text)

    def build(self):
        self.clear()
        top = ttk.Frame(self.root, padding=15)
        top.pack(fill='x')
        ttk.Label(top, text='Vehicle Service Centre', style='Title.TLabel').pack(side='left')
        ttk.Button(top, text='Disconnect', command=self.disconnect).pack(side='right')
        bar = ttk.Frame(self.root, padding=(15, 0, 15, 12))
        bar.pack(fill='x')
        ttk.Label(bar, text='Select table:').pack(side='left', padx=(0, 10))
        selector = ttk.Combobox(bar, textvariable=self.table, values=TABLES, state='readonly', width=24)
        selector.pack(side='left')
        selector.bind('<<ComboboxSelected>>', lambda event: self.load())
        ttk.Button(bar, text='Refresh records', command=self.load).pack(side='left', padx=10)
        ttk.Button(bar, text='Delete selected record', command=self.delete).pack(side='right')
        self.status = tk.StringVar()
        ttk.Label(self.root, textvariable=self.status, padding=(15, 4)).pack(fill='x')
        gridbox = ttk.Frame(self.root, padding=(15, 5))
        gridbox.pack(fill='both', expand=True)
        gridbox.rowconfigure(0, weight=1)
        gridbox.columnconfigure(0, weight=1)
        self.tree = ttk.Treeview(gridbox, show='headings', selectmode='browse')
        self.tree.grid(row=0, column=0, sticky='nsew')
        ys = ttk.Scrollbar(gridbox, orient='vertical', command=self.tree.yview)
        ys.grid(row=0, column=1, sticky='ns')
        xs = ttk.Scrollbar(gridbox, orient='horizontal', command=self.tree.xview)
        xs.grid(row=1, column=0, sticky='ew')
        self.tree.configure(yscrollcommand=ys.set, xscrollcommand=xs.set)
        self.form = ttk.LabelFrame(self.root, text='Insert a new record', padding=15)
        self.form.pack(fill='x', padx=15, pady=10)
        ttk.Label(self.root, text='Live MySQL connection | Select a row to delete | Refresh to see changes made in the SQL client',
                  padding=(15, 8)).pack(fill='x')
        self.load()

    def query(self, sql, params=(), dictionary=False):
        cursor = self.connection.cursor(dictionary=dictionary)
        try:
            cursor.execute(sql, params)
            return cursor.fetchall() if cursor.with_rows else cursor.rowcount
        finally:
            cursor.close()

    def load(self):
        table = self.table.get()
        if table not in TABLES:
            return
        try:
            self.columns = self.query(f'DESCRIBE `{table}`', dictionary=True)
            keys = [col['Field'] for col in self.columns]
            primary = next(col['Field'] for col in self.columns if col['Key'] == 'PRI')
            rows = self.query(f'SELECT * FROM `{table}` ORDER BY `{primary}`')
            self.tree.delete(*self.tree.get_children())
            self.tree['columns'] = keys
            for key in keys:
                self.tree.heading(key, text=key.replace('_', ' '))
                self.tree.column(key, width=180, minwidth=120, stretch=True)
            for row in rows:
                self.tree.insert('', 'end', values=['' if value is None else str(value) for value in row])
            self.status.set(f'{table} | {len(rows)} records | Connected to MySQL')
            self.make_form(table)
        except Exception as error:
            self.error(error)

    def make_form(self, table):
        for child in self.form.winfo_children():
            child.destroy()
        self.inputs = {}
        relations = self.query('SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME '
            'FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() '
            'AND TABLE_NAME=%s AND REFERENCED_TABLE_NAME IS NOT NULL', (table,))
        foreign = {row[0]: (row[1], row[2]) for row in relations}
        for index, col in enumerate(self.columns):
            name = col['Field']
            cell = ttk.Frame(self.form)
            cell.grid(row=index//4, column=index%4, sticky='ew', padx=6, pady=5)
            self.form.columnconfigure(index%4, weight=1)
            suffix = ' (optional)' if col['Null'] == 'YES' else ' *'
            ttk.Label(cell, text=name.replace('_', ' ') + suffix).pack(anchor='w')
            default = col['Default']
            if col['Type'].lower() == 'date':
                default = date.today().isoformat()
            elif col['Type'].lower().startswith('datetime'):
                default = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            var = tk.StringVar(value='' if default is None else str(default))
            values = CHOICES.get(name)
            if name in foreign:
                parent, key = foreign[name]
                parent = parent.upper()
                if parent not in TABLES or not key.replace('_', '').isalnum():
                    raise ValueError('Unexpected foreign key metadata.')
                values = [str(row[0]) for row in self.query(f'SELECT `{key}` FROM `{parent}` ORDER BY `{key}`')]
            if values is not None:
                widget = ttk.Combobox(cell, textvariable=var, values=values, state='readonly', width=23)
            else:
                widget = ttk.Entry(cell, textvariable=var, width=25)
            widget.pack(fill='x', pady=4)
            self.inputs[name] = var
        buttons = ttk.Frame(self.form)
        buttons.grid(row=(len(self.columns)+3)//4, column=0, columnspan=4, sticky='w', pady=8)
        ttk.Button(buttons, text='Insert record', command=self.insert).pack(side='left', padx=6)
        ttk.Label(buttons, text='Dates: YYYY-MM-DD | Times: YYYY-MM-DD HH:MM:SS | IDs are entered manually').pack(side='left', padx=10)

    def insert(self):
        try:
            values = [convert(self.inputs[col['Field']].get(), col) for col in self.columns]
            record = dict(zip([col['Field'] for col in self.columns], values))
            if 'End_Time' in record and record['End_Time'] <= record['Start_Time']:
                raise ValueError('End time must be after start time.')
            columns = ', '.join('`'+col['Field']+'`' for col in self.columns)
            marks = ', '.join(['%s'] * len(values))
            self.query(f'INSERT INTO `{self.table.get()}` ({columns}) VALUES ({marks})', values)
            self.load()
            messagebox.showinfo('Record inserted', 'The record was saved in MySQL. The table has been refreshed.')
        except (ValueError, InvalidOperation) as error:
            self.error(ValueError('Check the field values. ' + str(error)))
        except Exception as error:
            self.error(error)

    def delete(self):
        selected = self.tree.selection()
        if not selected:
            messagebox.showinfo('Select a record', 'Click the row you want to delete first.')
            return
        primary_index = next(i for i, col in enumerate(self.columns) if col['Key'] == 'PRI')
        key = self.columns[primary_index]['Field']
        value = self.tree.item(selected[0], 'values')[primary_index]
        table = self.table.get()
        if not messagebox.askyesno('Confirm deletion', f'Delete {table} record with {key} = {value}?'):
            return
        try:
            count = self.query(f'DELETE FROM `{table}` WHERE `{key}` = %s', (value,))
            self.load()
            messagebox.showinfo('Delete result', 'Record deleted from MySQL.' if count else 'Record was already removed. Table refreshed.')
        except Exception as error:
            self.error(error)

    def disconnect(self):
        if self.connection:
            self.connection.close()
            self.connection = None
        self.login()

    def close(self):
        if self.connection:
            self.connection.close()
        self.root.destroy()


if __name__ == '__main__':
    root = tk.Tk()
    App(root)
    root.mainloop()
