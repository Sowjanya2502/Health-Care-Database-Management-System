import mysql.connector
from mysql.connector import Error
import tkinter as tk
from tkinter import *
from tkinter import ttk, messagebox
#from PIL import Image, ImageTk

# Function to establish MySQL conn
def database_mysql_connection():
    try:
        conn = mysql.connector.connect(
            host="cssql.seattleu.edu",  
            user="am_dpadala",  
            password="KLsijv1KlJGN+PH0", 
            database="am_dpadala"  
        )
        if conn.is_connected():
            print("Connected to MySQL Database")
        return conn
    except Error as e:
        messagebox.showerror("Connection Error", f"Error connecting to MySQL: {e}")
        return None
    
#This function checks if a user exists in the database with the provided email and password. It also verifies if the user has the necessary role to access the system.
def authenticate_user(Email_ID, Password):
    allowed_roles = {2, 3, 6} #allowed employees based on their role i.e., Doctor, Surgeon, Patient Care Technician
    conn = database_mysql_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor()
        # Fetch the Role_ID along with the email and password
        cursor.execute("SELECT Role_ID FROM Employee WHERE Email_ID = %s AND Password = %s", (Email_ID, Password))
        user = cursor.fetchone()
        cursor.close()
        
        if user is not None:
            role_id = user[0]  # Assuming Role_ID is the first column in the result
            return role_id in allowed_roles  # Check if the role_id is in the allowed roles
        else:
            return False  # Invalid credentials
    except Error as e:
        messagebox.showerror("Query Error", f"Error executing query: {e}")
        return False
    finally:
        conn.close()  # Ensuring the connection is closed in all cases
    

def healthcare_query_page():
    login_page.destroy()
    # This Function will execute queries and display results
    def execution_query():
        key = var.get() #getting the selected queries from the dropdown box
        
        if key not in queries:
            messagebox.showwarning("Input Error","Please select a valid query.")
            return
        
        query = queries[key] #extracting SQL queries from dictionary
        params = ()
        
        # Handling parameterized queries or queries that need user input
        if key == "Patient History":
            patient_id = userEntryParameter.get()
            if not patient_id.isdigit():
                messagebox.showerror("Input Error", "Please enter a valid Patient ID.")
                return
            params = (patient_id,)#given patient ID as parameter
        
        elif key == "State-wise Cases for a Disease":
            disease_name = userEntryParameter.get()
            if not disease_name:
                messagebox.showerror("Input Error", "Please enter a Disease Name.")
                return
            params = (disease_name,) # disease name as parmeter
        
        elif key == "Total Appointments Per Doctor":
            Employee_ID = userEntryParameter.get()
            if not Employee_ID.isdigit():
                messagebox.showerror("Input Error", "Please enter a valid Doctor ID.")
                return
            params = (Employee_ID,)

        elif key == "List of Appointments by Status":
            status = userEntryParameter.get().strip().lower()
            if status not in ["completed", "cancelled", "scheduled"]:
                messagebox.showerror("Input Error", "Please enter 'Canceled' as status.")
                return
            params = (status,)

        elif key == "Patients by Blood Group":
            blood_group = userEntryParameter.get().strip().upper()
            valid_blood_groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
            if blood_group not in valid_blood_groups:
                messagebox.showerror("Input Error", "Please enter a valid Blood Group (e.g., A+, O-).")
                return
            params = (blood_group,)


        conn = database_mysql_connection()
        if not conn:
            return

        try:
            cursor = conn.cursor(dictionary=True) #showing column names in output
            cursor.execute(query, params)
            results = cursor.fetchall()
            cursor.close()
            conn.close()
            
            if results:
                display_results(results) #Diplaying output in GUI
            else:
                messagebox.showinfo("No Data", "No results found for this query.")
        except Error as e:
            messagebox.showerror("Query Error", f"Error executing query: {e}")

    # This Function will display query results in Tkinter
    def display_results(results):
        for widget in frame_results.winfo_children():
            widget.destroy() # clears old data before showing new results

        if not results:
            return
            
        columns = list(results[0].keys()) #getting the column names
        frame = tk.Frame(frame_results)
        frame.pack(expand=True, fill="both")
        tree = ttk.Treeview(frame, columns=columns, show="headings")# creating a table Treeview to display query results.
        '''A treeview widget displays a hierarchy of items and allows users to browse through it. 
            One or more attributes of each item can be displayed as columns to the right of the tree.'''
        h_scroll = ttk.Scrollbar(frame, orient="horizontal", command=tree.xview)
        v_scroll = ttk.Scrollbar(frame, orient="vertical", command=tree.yview)
        tree.configure(xscrollcommand=h_scroll.set, yscrollcommand=v_scroll.set)

        for col in columns:
            tree.heading(col, text=col) #setting column headers
            tree.column(col, width=120, anchor="center") #setting column width

        for row in results:
            tree.insert("", "end", values=list(row.values())) #Inserting the data
        
        tree.pack(side="left", fill="both", expand=True)
        v_scroll.pack(side="right", fill="y")
        h_scroll.pack(side="bottom", fill="x")

    # Healthcare Database GUI Setup
    root = tk.Tk()
    root.title("Healthcare Database - Group 4")
    
    root.geometry("1000x700") #window size
    # Load background image
    background = PhotoImage(file="logo.png")

    # Show image using label and make it fill the entire window
    label_bg = tk.Label(root, image=background)
    label_bg.place(relwidth=1, relheight=1)


    # # Load and set background image
    # bg_image = Image.open("healthcare_bg.png")

    # bg_image = bg_image.resize((1000, 700), Image.BICUBIC)  # Resize to match window
    # bg_photo = ImageTk.PhotoImage(bg_image)

    # bg_label = tk.Label(root, image=bg_photo)
    # bg_label.place(relwidth=1, relheight=1)  # Fullscreen background

    # Header Label
    header_label = tk.Label(root, text="Healthcare Database Query System", font=("Arial", 24, "bold"), bg="#F0F2F5", fg="#333")
    header_label.pack(pady=10)

    # Main Frame
    frame_top = tk.Frame(root, bg="#ffffff", relief=tk.GROOVE, borderwidth=2, pady=10, padx=20)
    frame_top.pack(pady=20, padx=10, fill="x") #selecting the queries

    # Frame for displaying the result of the query
    frame_results = tk.Frame(root, bg="#f4f4f4", relief=tk.GROOVE) #displaying the result of that query
    frame_results.pack(expand=True, fill="both", padx=20, pady=10)

    # Creating a Dropdown menu for Query Selection
    var = tk.StringVar()
    labelQuery = tk.Label(frame_top, text="Select Query:", font=("Arial", 14), bg="#ffffff")
    labelQuery.grid(row=0, column=0, padx=10, pady=20)

    query_options = [
        "Patient History",
        "Most Diagnosed Diseases in Last 2 Years",
        "Patient Visits by Age Group",
        "State-wise Cases for a Disease",
        "Revenue Generated by Each Department",
        "Patients with the Most Visits",
        "Total Appointments Per Doctor",
        "List of Appointments by Status",
        "Patients by Blood Group"
    ]
    queryBox = ttk.Combobox(frame_top, textvariable=var, values=query_options, state="readonly", width=40)
    queryBox.grid(row=0, column=1, padx=10)

    # Adding Entry field/ Input box for for users to enter values
    userEntryParameter = tk.Entry(frame_top, font=("Arial", 12), width=25, relief=tk.SOLID, borderwidth=1)
    userEntryParameter.grid(row=0, column=2, padx=10, pady=10)

    # Run query Button
    runButton = tk.Button(frame_top, text="Run Query", command=execution_query, font=("Arial", 12, "bold"), bg="#28A745", fg="#FFF", relief=tk.FLAT, padx=10)
    runButton.grid(row=0, column=3, padx=10, pady=10)

    # SQL Queries Dictionary
    queries = {
        "Patient History": """
            SELECT  
                p.Patient_ID,  
                CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name, 
                p.Gender, p.Age, p.Blood_Group, p.Height, p.Weight, 
                a.Appointment_Date, a.Employee_ID, 
                CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name, 
                r.Role_Desc 
            FROM Patient p 
            JOIN Appointment a ON p.Patient_ID = a.Patient_ID 
            JOIN Employee e ON a.Employee_ID = e.Employee_ID 
            JOIN Role r ON e.Role_ID = r.Role_ID 
            WHERE p.Patient_ID = %s
            ORDER BY a.Appointment_Date DESC;
        """,

        "Most Diagnosed Diseases in Last 2 Years": """
            SELECT d.Name AS Disease_Name,  
                COUNT(pd.Patient_Disease_ID) AS Diagnosed_Count 
            FROM Disease d 
            JOIN Patient_Disease pd ON d.Disease_ID = pd.Disease_ID 
            JOIN Patient_Register pr ON pd.Patient_Register_ID = pr.Patient_Register_ID 
            WHERE pr.Admitted_On >= DATE_SUB(NOW(), INTERVAL 2 YEAR)  
            GROUP BY d.Name 
            ORDER BY Diagnosed_Count DESC;
        """,

        "Patient Visits by Age Group": """
            SELECT  
                CASE  
                    WHEN p.Age BETWEEN 0 AND 15 THEN '0-15 (Children)' 
                    WHEN p.Age BETWEEN 16 AND 35 THEN '16-35 (Young Adults)' 
                    WHEN p.Age BETWEEN 36 AND 50 THEN '36-50 (Middle Aged)' 
                    WHEN p.Age BETWEEN 51 AND 100 THEN '51-100 (Senior Adults)' 
                END AS Age_Group, 
                COUNT(DISTINCT a.Patient_ID) AS Total_Visits 
            FROM Patient p 
            JOIN Appointment a ON a.Patient_ID = p.Patient_ID 
            GROUP BY Age_Group 
            ORDER BY Total_Visits DESC;
        """,

        "State-wise Cases for a Disease": """
            SELECT a.State, d.Name AS Disease, COUNT(pd.Patient_Disease_ID) AS Total_Cases
            FROM Patient_Disease pd 
            JOIN Patient_Register pr ON pd.Patient_Register_ID = pr.Patient_Register_ID 
            JOIN Patient p ON pr.Patient_ID = p.Patient_ID 
            JOIN Patient_Address pa ON p.Patient_ID = pa.Patient_ID 
            JOIN Address a ON pa.Address_ID = a.Address_ID 
            JOIN Disease d ON pd.Disease_ID = d.Disease_ID 
            WHERE d.Name = %s
            GROUP BY a.State 
            ORDER BY Total_Cases DESC;
        """,

        "Revenue Generated by Each Department": """
            SELECT  
                d.Department_Name,  
                COUNT(pb.Patient_Billing_ID) AS Total_Bills,  
                SUM(pb.Amount) AS Total_Department_Revenue
            FROM Department d 
            JOIN Employee e ON d.Department_ID = e.Department_ID 
            JOIN Appointment a ON e.Employee_ID = a.Employee_ID 
            JOIN Patient_Register pr ON a.Patient_ID = pr.Patient_ID 
            JOIN Patient_Billing pb ON pr.Patient_Register_ID = pb.Patient_Register_ID 
            GROUP BY d.Department_Name 
            ORDER BY Total_Department_Revenue DESC;
        """,

        "Patients with the Most Visits": """
            SELECT p.Patient_ID, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name, COUNT(a.Appointment_ID) AS Visit_Count
            FROM Patient p 
            JOIN Appointment a ON p.Patient_ID = a.Patient_ID 
            GROUP BY p.Patient_ID 
            ORDER BY Visit_Count DESC 
            LIMIT 10;
        """,
        
        "Total Appointments Per Doctor": """
            SELECT 
                e.Employee_ID, 
                CONCAT(e.First_Name, ' ', e.Last_Name) AS Doctor_Name, 
                COUNT(a.Appointment_ID) AS Total_Appointments
            FROM Employee e
            JOIN Appointment a ON e.Employee_ID = a.Employee_ID
            WHERE e.Employee_ID= %s
            GROUP BY e.Employee_ID, Doctor_Name
            ORDER BY Total_Appointments DESC;
    """,
    "List of Appointments by Status":
    """
        SELECT 
            a.Appointment_ID, 
            CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name, 
            CONCAT(e.First_Name, ' ', e.Last_Name) AS Doctor_Name, 
            a.Appointment_Date, 
            a.Status
        FROM Appointment a
        JOIN Patient p ON a.Patient_ID = p.Patient_ID
        JOIN Employee e ON a.Employee_ID = e.Employee_ID
        WHERE a.Status = %s
        ORDER BY a.Appointment_Date DESC;
    """,
    "Patients by Blood Group":"""
        SELECT 
            p.Blood_Group, 
            COUNT(p.Patient_ID) AS Patient_Count
        FROM Patient p
        WHERE p.Blood_Group = %s
        GROUP BY p.Blood_Group
        ORDER BY Patient_Count DESC;
    """
    }

    # Run Tkinter Application by keeping the window open
    root.mainloop()


# Function to handle login button click
def on_login(): #This function is triggered when the user clicks the "Login" button.
    Email_ID = entry_username.get()
    Password = entry_password.get()
    
    if authenticate_user(Email_ID, Password):
        messagebox.showinfo("Login Success", "You are successfully logged in!")
        healthcare_query_page()
    else:
        messagebox.showerror("Login Failed", "Invalid username or password.")




# Creating a Login GUI Setup for authorized users only
login_page = tk.Tk()
login_page.title("Healthcare Database system")
login_page.geometry("800x600")# window size
icon = tk.PhotoImage(file="logo.png")
login_page.iconphoto(False, icon)

login_page.configure(bg="#E0FFFF") #light cyan
background= PhotoImage(file="healthcare_bg.png")

# Showing image using label and make it fill the entire window
label_bg = tk.Label(login_page, image=background)
label_bg.place(relwidth=1, relheight=1)  # Fill the entire window

# Header Label is created to greet the user and prompt them to log in
header_label = tk.Label(login_page, text="Welcome to Healthcare database system!\n Please Login", font=("Arial", 20, "bold"), bg="#E0FFFF")
header_label.pack(pady=20)

# Username and Password Labels and Entries
label_username = tk.Label(login_page, text="Email ID:", bg="#E0FFFF", font=("Arial", 16))
label_username.pack(pady=5)

entry_username = tk.Entry(login_page, width=30,  relief=tk.GROOVE )
entry_username.pack(pady=5)

label_password = tk.Label(login_page, text="Password:",bg="#E0FFFF", font=("Arial", 16))
label_password.pack(pady=5)

entry_password = tk.Entry(login_page, show='*', width=30, relief=tk.GROOVE )
entry_password.pack(pady=5)

# Login Button
login_button = tk.Button(login_page, text="Login", command=on_login, font=("Arial", 16, "bold"), bg="#28A745", fg="#FFF", relief=tk.RAISED )
login_button.pack(pady=20)

# Start the login window
login_page.mainloop()