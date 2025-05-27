import tkinter as tk
from tkinter import messagebox

class SudokuGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Sudoku Solver")
        self.cells = {}  # Dictionary to store cell entries
        self.selected = None  # Currently selected cell
        
        # Create main frame
        self.main_frame = tk.Frame(self.root, padx=20, pady=20)
        self.main_frame.pack(expand=True)
        
        self.create_board()
        self.create_buttons()
        self.create_number_pad()
        
    def create_board(self):
        # Create the main grid frame
        grid_frame = tk.Frame(
            self.main_frame,
            highlightbackground="black",
            highlightthickness=2
        )
        grid_frame.pack()
        
        # Create cells
        for i in range(9):
            for j in range(9):
                # Calculate border thickness based on position
                border_right = 2 if (j + 1) % 3 == 0 and j < 8 else 1
                border_bottom = 2 if (i + 1) % 3 == 0 and i < 8 else 1
                
                # Using Entry widget with adjusted dimensions
                cell = tk.Entry(
                    grid_frame,
                    width=3,
                    font=('Arial', 18, 'bold'),
                    justify='center',
                    bd=1,
                    relief="solid"
                )
                
                cell.grid(
                    row=i,
                    column=j,
                    padx=(1, border_right),
                    pady=(1, border_bottom),
                    ipady=8,
                    ipadx=8
                )
                
                # Bind events
                cell.bind('<FocusIn>', lambda e, row=i, col=j: self.cell_clicked(row, col))
                cell.bind('<Key>', self.validate_input)
                
                self.cells[(i, j)] = cell
                
                # Configure grid weights
                grid_frame.grid_rowconfigure(i, weight=1)
                grid_frame.grid_columnconfigure(j, weight=1)
    
    def validate_input(self, event):
        if self.selected:
            # Only allow numbers 1-9
            if event.char in '123456789':
                row, col = self.selected
                if self.is_valid_move(row, col, int(event.char)):
                    return True
                else:
                    messagebox.showwarning(
                        "Invalid Move",
                        f"Cannot place {event.char} here. This number already exists in the same row, column, or 3x3 box."
                    )
            # Allow backspace and delete
            elif event.keysym in ('BackSpace', 'Delete'):
                return True
        # Prevent default action for other keys
        return "break"
    
    def create_buttons(self):
        button_frame = tk.Frame(self.main_frame)
        button_frame.pack(pady=20)
        
        solve_button = tk.Button(
            button_frame,
            text="Solve",
            command=self.solve_board,
            font=('Arial', 12, 'bold'),
            padx=30,
            pady=10,
            bg='#4CAF50',
            fg='white'
        )
        solve_button.pack(side=tk.LEFT, padx=10)
        
        clear_button = tk.Button(
            button_frame,
            text="Clear",
            command=self.clear_board,
            font=('Arial', 12, 'bold'),
            padx=30,
            pady=10,
            bg='#f44336',
            fg='white'
        )
        clear_button.pack(side=tk.LEFT, padx=10)
    
    def create_number_pad(self):
        numpad_frame = tk.Frame(self.main_frame)
        numpad_frame.pack(pady=10)
        
        # Create number buttons 1-9
        for i in range(9):
            btn = tk.Button(
                numpad_frame,
                text=str(i + 1),
                command=lambda x=i+1: self.number_clicked(x),
                width=4,
                height=2,
                font=('Arial', 12),
                bg='#e0e0e0'
            )
            btn.grid(row=0, column=i, padx=2)
        
        # Add clear cell button
        clear_cell_btn = tk.Button(
            numpad_frame,
            text="X",
            command=lambda: self.number_clicked(0),
            width=4,
            height=2,
            font=('Arial', 12, 'bold'),
            bg='#ff9800',
            fg='white'
        )
        clear_cell_btn.grid(row=0, column=9, padx=2)
    
    def is_valid_move(self, row, col, num):
        # Check row
        for j in range(9):
            if j != col and self.cells[(row, j)].get() == str(num):
                return False
        
        # Check column
        for i in range(9):
            if i != row and self.cells[(i, col)].get() == str(num):
                return False
        
        # Check 3x3 box
        box_row, box_col = 3 * (row // 3), 3 * (col // 3)
        for i in range(box_row, box_row + 3):
            for j in range(box_col, box_col + 3):
                if (i != row or j != col) and self.cells[(i, j)].get() == str(num):
                    return False
        
        return True
    
    def cell_clicked(self, row, col):
        # Reset previous selection
        if self.selected:
            self.cells[self.selected].config(bg='white')
        
        # Update new selection
        self.selected = (row, col)
        self.cells[self.selected].config(bg='#bbdefb')
    
    def number_clicked(self, number):
        if self.selected:
            row, col = self.selected
            if number == 0:  # Clear cell
                self.cells[self.selected].delete(0, tk.END)
            else:
                if self.is_valid_move(row, col, number):
                    self.cells[self.selected].delete(0, tk.END)
                    self.cells[self.selected].insert(0, str(number))
                else:
                    messagebox.showwarning(
                        "Invalid Move",
                        f"Cannot place {number} here. This number already exists in the same row, column, or 3x3 box."
                    )
    
    def get_board(self):
        board = []
        for i in range(9):
            row = []
            for j in range(9):
                value = self.cells[(i, j)].get()
                row.append(int(value) if value else 0)
            board.append(row)
        return board
    
    def set_board(self, board):
        for i in range(9):
            for j in range(9):
                self.cells[(i, j)].delete(0, tk.END)
                if board[i][j] != 0:
                    self.cells[(i, j)].insert(0, str(board[i][j]))
                    self.cells[(i, j)].config(fg='#283593')
    
    def clear_board(self):
        for cell in self.cells.values():
            cell.delete(0, tk.END)
            cell.config(bg='white', fg='black')
        self.selected = None
    
    def solve_board(self):
        try:
            board = self.get_board()
            if self.solve_sudoku(board):
                self.set_board(board)
            else:
                messagebox.showerror("Error", "No solution exists!")
        except Exception as e:
            messagebox.showerror("Error", "An error occurred while solving the puzzle. Please check your inputs.")
    
    def solve_sudoku(self, board):
        empty = None
        for i in range(9):
            for j in range(9):
                if board[i][j] == 0:
                    empty = (i, j)
                    break
            if empty:
                break
        
        if not empty:
            return True
        
        row, col = empty
        for num in range(1, 10):
            if self.is_valid(board, row, col, num):
                board[row][col] = num
                if self.solve_sudoku(board):
                    return True
                board[row][col] = 0
        
        return False
    
    def is_valid(self, board, row, col, num):
        # Check row
        for x in range(9):
            if board[row][x] == num:
                return False
        
        # Check column
        for x in range(9):
            if board[x][col] == num:
                return False
        
        # Check 3x3 box
        start_row, start_col = 3 * (row // 3), 3 * (col // 3)
        for i in range(3):
            for j in range(3):
                if board[i + start_row][j + start_col] == num:
                    return False
        
        return True

def main():
    root = tk.Tk()
    app = SudokuGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()