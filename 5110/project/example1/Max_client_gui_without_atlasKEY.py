from __future__ import print_function
import socket
import threading
import tkinter as tk
import tkinter.scrolledtext as tkst
from tkinter import filedialog
import os
import pymongo
import pickle
import os.path
from googleapiclient.discovery import build
import googleapiclient
import io
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

client_max = pymongo.MongoClient('mongodb://root:password1@ds149146.mlab.com:49146/5110-database')
db = client_max['5110-database']
collection = db['cs5110-collection']

HOST = '127.0.0.1'
PORT = 60010

login = '0'
broadcast = '1'
secret = '2'
exit = '8'
full = 'F'
existed = 'E'
shutdown = 'X'


class Client(tk.Tk):
    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)
        self.__nickname = 'USER'
        self.prompt = ''
        self.__socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.__login = False

        self.message_line = 0

        self.name = tk.StringVar()
        self.server = tk.StringVar()

        self.resizable(False, False)
        container = tk.Frame(self)
        container.pack(side='top', fill='both', expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}

        frame_name = LoginFrame.__name__
        frame = LoginFrame(container, self)
        self.frames[frame_name] = frame

        test_max = "123456"

        frame_name = ChattingFrame.__name__
        frame = ChattingFrame(container, self, test_max)
        self.frames[frame_name] = frame

        self.raise_frame("LoginFrame")

    def raise_frame(self, frame_name):
        for frame in self.frames.values():
            frame.grid_remove()
        frame = self.frames[frame_name]
        frame.grid(row=0, column=0, sticky='ewsn')
        frame.tkraise()

    def get_frame_by_name(self, frame_name):
        for frame in self.frames.values():
            if str(frame.__class__.__name__) == frame_name:
                return frame
        print(frame_name + "NOT FOUND!")
        return None


    def login(self, user_name):
        self.__nickname = str(user_name).ljust(8)
        self.prompt = '[@' + self.__nickname + ']> '
        try:
            self.__socket.connect((HOST, PORT))
            # if connection succeeds, send login message
            send_message = (login + self.__nickname).encode()
            self.__socket.sendall(send_message)
            data = self.__socket.recv(1024)
            if str(data.decode()).startswith(full):
                raise ValueError("[System]Chatroom Full!")
            elif str(data.decode()).startswith(existed):
                raise ValueError("[System]You already login!")
            elif str(data.decode()).startswith(login):
                self.__login = True
                message = data.decode()
                # just in case
                if message[1:9] != self.__nickname:
                    raise ValueError("[System]Server Went Wrong")
                self.raise_frame("ChattingFrame")
                display_message = "[System] Login Success, type \"\help\" to get command tips.\n"
                self.get_frame_by_name('ChattingFrame').add_message(display_message, "Blue")
                # sent list of current users
                self.get_frame_by_name('ChattingFrame').update_user_window(message[9:])
                self.get_frame_by_name('ChattingFrame').update_username(message)

                thread = threading.Thread(target=self.receive_message_thread)
                thread.setDaemon(True)
                thread.start()

        except ValueError as ve:
            self.get_frame_by_name('LoginFrame').add_message(ve)
            self.name.set("")
            self.__socket.close()

    def shut_down(self):
        self.__login = False
        self.__socket.close()
        self.destroy()

    def help_menu(self):
        message = "------------------------------------------------------\n" \
                  "          Instruction of 5110 Common Room             \n" \
                  "            (0)[\exit] to leave the chat              \n" \
                  "(1)[@Receiver(space)message] send to a specific person\n" \
                  "          (2)Double Click to get one's name           \n" \
                  "------------------------------------------------------\n"
        self.get_frame_by_name('ChattingFrame').add_message(message, "OrangeRed")

    def display_broadcast(self, message):
        sender = message[1:9]
        text = message[9:]
        self.get_frame_by_name("ChattingFrame").\
            add_message('[Public][@' + sender + ']> ' + text, "black")

    def display_secret(self, message):
        sender = message[1:9]
        text = message[9:]
        self.get_frame_by_name("ChattingFrame").\
            add_message('[Secret][@' + sender + ']> ' + text, "green")

    def display_system_message(self, message):
        sender = message[1:9]
        if sender[7] is not ' ':
            sender = sender + ' '
        if message[0] == login:
            self.get_frame_by_name("ChattingFrame").\
                add_message("[System] " + sender + "has joined the chat\n", "blue")
        elif message[0] == exit:
            self.get_frame_by_name("ChattingFrame"). \
                add_message("[System] " + sender + "has left the chat\n", "blue")
        self.get_frame_by_name("ChattingFrame"). \
            update_user_window(message[9:])

    def receive_message_thread(self):
        while self.__login:
            try:
                data = self.__socket.recv(1024).decode()
                if str(data).startswith(login) or str(data).startswith(exit):
                    self.display_system_message(data)
                elif str(data).startswith(broadcast):
                    self.display_broadcast(data)
                elif str(data).startswith(secret):
                    self.display_secret(data)
                elif str(data).startswith(shutdown):
                    self.shutdown()
            except Exception:
                print("[Client] Connection Close")
                self.__login = False
                self.__socket.close()
                self.destroy()

    def send_message(self, message):
        send = False
        op_code = ""
        if str(message).startswith("\exit"):
            message = ""
            op_code = exit
        elif str(message).startswith("\help"):
            self.help_menu()
        elif str(message).startswith("@"):
            op_code = secret
            message = message[1:]
            send = True
        else:
            op_code = broadcast
            send = True

        if len(op_code):
            send_message = (op_code + self.__nickname + message).encode()
            self.__socket.sendall(send_message)
        if op_code == exit:
            self.__login = False
            self.__socket.close()
            self.__socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.destroy()
        return send


class LoginFrame(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        self.receive_message_window = tk.Label(self, text="Welcome To Our Chatroom!")
        self.receive_message_window['font'] = ('Calibri', 14)
        self.receive_message_window.grid(row=0, columnspan=4, padx=40, sticky="nsew")

        tk.Label(self, text=" Username :", font=("Callbri", 10)).grid(row=1, column=0, pady=20)
        entry_name = tk.Entry(self, textvariable=self.controller.name)
        entry_name.grid(row=1, column=1, ipadx=20, padx=15, pady=10)

        global username_verify
        global password_verify
        username_verify = self.controller.name

        password_verify = tk.StringVar()
        tk.Label(self, text=" Password :", font=("Callbri", 10)).grid(row=2, column=0, pady=20)
        entry_name = tk.Entry(self, textvariable=password_verify)
        entry_name.grid(row=2, column=1, ipadx=20, padx=15, pady=10)

        self.login_button = tk.Button(self, text="LOGIN", bg="cyan", width=20, height=2, command=self.login_verify)
        self.login_button.grid(row=3, columnspan=10, padx=10, pady=10)

        self.login_button = tk.Button(self, text="REGISTER", width=20, height=2, command=self.register)
        self.login_button.grid(row=4, columnspan=10, padx=10, pady=10)


        entry_name.bind('<KeyRelease-Return>', self.login_verify)
        self.login_button.bind('<Return>', self.login_verify)


    def login_verify(self):
        global username_login
        username_login = username_verify.get()
        password_login = password_verify.get()

        chatroom_users = db.chatroom_users
        login_status = chatroom_users.find_one({"username": username_login})
        if login_status is None:
            self.username_not_found()
        elif login_status["password"] == password_login:
            self.login_success()
        else:
            self.password_wrong()

    def login_success(self):
        self.delete_window1()
        # global screen_success
        # screen_success = tk.Toplevel(self)
        # screen_success.title("Success")
        # screen_success.geometry("150x100")
        # tk.Label(screen_success, text="Login Success").pack()
        # tk.Button(screen_success, text="OK", command=self.delete_window1).pack()

    def password_wrong(self):
        global screen_wrong_p
        screen_wrong_p = tk.Toplevel(self)
        screen_wrong_p.title("Wrong Password")
        screen_wrong_p.geometry("150x100")
        tk.Label(screen_wrong_p, text="Wrong Password").pack()
        tk.Button(screen_wrong_p, text="OK", command=self.delete_window2).pack()

    def username_not_found(self):
        global screen_no_found
        screen_no_found = tk.Toplevel(self)
        screen_no_found.title("Username not found")
        screen_no_found.geometry("150x100")
        tk.Label(screen_no_found, text="Username not found!").pack()
        tk.Button(screen_no_found, text="OK", command=self.delete_window3).pack()

    def delete_window1(self):
        # screen_success.destroy()
        # self.withdraw()
        self.login_main()

    def delete_window2(self):
        screen_wrong_p.destroy()

    def delete_window3(self):
        screen_no_found.destroy()

    def register(self):
        global screenRe
        screenRe = tk.Toplevel(self)
        screenRe.title("Register")
        screenRe.geometry("300x250")
        global username
        global password
        username = tk.StringVar()
        password = tk.StringVar()
        global username_entry
        global password_entry
        tk.Label(screenRe, text="Please enter details below").pack()
        tk.Label(screenRe, text="").pack()
        tk.Label(screenRe, text="Username * ").pack()
        username_entry = tk.Entry(screenRe, textvariable=username)
        username_entry.pack()
        tk.Label(screenRe, text="Password * ").pack()
        password_entry = tk.Entry(screenRe, textvariable=password)
        password_entry.pack()
        tk.Label(screenRe, text="").pack()
        tk.Button(screenRe, text="Register", width=10, height=1, command=self.register_user).pack()

    def register_user(self):
        username_info = username.get()
        password_info = password.get()

        chatroom_user = {"username": username_info, "password": password_info}
        chatroom_users = db.chatroom_users
        chatroom_users.insert_one(chatroom_user).inserted_id
        tk.Label(screenRe, text="Registration Success", fg='green', font=("Calibri", 11)).pack()

        global screenRe_success
        screenRe_success = tk.Toplevel(self)
        screenRe_success.title("Registration success")
        screenRe_success.geometry("150x100")
        tk.Label(screenRe_success, text="Registration success!").pack()
        tk.Button(screenRe_success, text="Back to Login page", command=self.delete_window4).pack()

    def delete_window4(self):
        screenRe.destroy()
        screenRe_success.destroy()

    def login_main(self, event=None):
        user_name = self.controller.name.get(),
        if len(user_name[0]) > 8:
            self.add_message('[System] User Name Limit <= 8 characters')
            self.controller.name.set("")
            return
        elif str(user_name[0]).isspace() or len(user_name[0]) == 0:
            self.add_message('[System] User Name [ ] is not available')
            self.controller.name.set("")
            return

        self.controller.connecting_thread = threading.Thread(target=self.controller.login, args=user_name)
        self.controller.connecting_thread.setDaemon(True)
        self.controller.connecting_thread.start()
    # def logout(self, event=None):
    #    self.controller.__login = False
    #    self.controller.destroy()

    def add_message(self, new_message):
        self.receive_message_window["text"] = new_message


class ChattingFrame(tk.Frame):
    global downloadVar
    downloadVar = True
    def __init__(self, parent, controller, test_max):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        self.receive_message_window = tkst.ScrolledText(self, width=60, height=20, undo=True)
        self.receive_message_window['font'] = ('consolas', 12)
        self.receive_message_window.grid(row=2, column=0, padx=10, pady=0, sticky="nsew")

        self.type_message_window = tk.Text(self, width=40, height=5, undo=True)
        self.type_message_window['font'] = ('consolas', 12)
        self.type_message_window.grid(row=3, padx=10, pady=20, rowspan=2, sticky="nsew")

        test1 = test_max[0]
        title = "HOST: " + HOST + " / PORT:" + str(PORT)
        # title = "HOST: " + HOST + " / PORT:" + str(PORT) + " / Username:" + str(username_verify.get())
        self.members = tk.Label(self, width=15, text=title)
        self.members['font'] = ('consolas', 9)
        self.members.grid(row=0, column=0, padx=10, pady=5, sticky="nsew")

        self.members = tk.Label(self, width=15, text="Users")
        self.members['font'] = ('consolas', 9)
        self.members.grid(row=1, column=1, padx=10, pady=5, sticky="nsew")

        self.userName = tk.Label(self, width=15, text="Username: ")
        self.userName['font'] = ('consolas', 9)
        self.userName.grid(row=1, column=0, padx=10, pady=2, sticky="nsew")

        self.chatroom_member_window = tk.Listbox(self, width=15, height=5, selectmode="browse")
        self.chatroom_member_window['font'] = ('consolas', 12)
        self.chatroom_member_window.grid(row=2, column=1, padx=10, pady=0, sticky="nsew")

        self.send_button = tk.Button(self, text="SEND",bg="cyan", width=10, command=self.send_message_from__gui__button)
        self.send_button.grid(row=3, column=1, padx=10)

        self.login_button = tk.Button(self, text='OPEN FILE', bg="cyan", width=10, command=self.UploadAction)
        self.login_button.grid(row=5, column=1, padx=20)


        self.logout_button = tk.Button(self, text="EXIT", width=10, bg="white", command=self.logout)
        self.logout_button.grid(row=4, column=1, padx=10)

        self.type_message_window.bind('<KeyRelease-Return>', self.send_message_from__gui)
        self.logout_button.bind('<Return>', self.logout)
        self.chatroom_member_window.bind('<Double-Button-1>', self.get_name_for_secret)
        print(downloadVar)
        self.downloadButton = tk.Button(self, text='DOWNLOAD FILE', bg="cyan", width=20, command=self.downloadButtons)
        self.downloadButton.grid(row=1, column=1, padx=10)
        # prevent receive_message_window from input
        self.receive_message_window.config(state=tk.DISABLED)

    def downloadButtons(self):
        if downloadVar is True:
            print("in downloadButtons function", downloadVar)
            self.downloadButton = tk.Button(self, text='DOWNLOAD FILE', bg="cyan", width=20,
                                            command=self.downloadFile)
            self.downloadButton.grid(row=1, column=1, padx=10)
        else:
            print("in downloadButtons function", downloadVar)
            self.downloadButton = tk.Button(self, text='DOWNLOAD FILE', bg="cyan", width=20,
                                            command=self.DownloadAction(file['id']))
            self.downloadButton.grid(row=1, column=1, padx=10)

    def downloadFile(self):
        print("i got here", str(self.receive_message_window.get("1.0", tk.END))[-34:])
        message = str(self.receive_message_window.get("1.0", tk.END))[-34:]
        self.downloadButton = tk.Button(self, text='DOWNLOAD FILE', bg="cyan", width=20,
                                                command=self.DownloadAction(message))

    def UploadAction(self):
        global downloadVar
        downloadVar = False
        filename = filedialog.askopenfilename()
        file_metadata = {'name': filename}
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                creds = pickle.load(token)
            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)
        service = build('drive', 'v3', credentials=creds)
        media = googleapiclient.http.MediaFileUpload(filename, mimetype='image/jpeg')
        global file
        file = service.files().create(body=file_metadata, media_body=media, fields='id, webViewLink').execute()
        self.add_message('[You  ]' + self.controller.prompt + file['webViewLink'] + '\n', "CornflowerBlue")
        self.add_message('[File  ]' + self.controller.prompt + file['id'] + '\n', "CornflowerBlue")
        self.controller.message_line += 1
        self.downloadButton = tk.Button(self, text='DOWNLOAD FILE', bg="cyan", width=20, command=self.DownloadAction(file['id']))



    def DownloadAction(self, filename):
        global downloadVar
        downloadVar = False
        print(downloadVar)
        if os.path.exists('token.pickle'):
            with open('token.pickle', 'rb') as token:
                creds = pickle.load(token)
            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)
        self.downloadButton.grid(row=1, column=1, padx=10)
        service = build('drive', 'v3', credentials=creds)
        request = service.files().get_media(fileId=filename)
        fh = io.FileIO("downloadedfile.jpg", 'wb')
        downloader = googleapiclient.http.MediaIoBaseDownload(fh, request)
        print('downloading...')





    def send_message_from__gui__button(self, event=None):
        try:
            message = self.type_message_window.get("1.0", tk.END + '-1c')
            if self.controller.send_message(message + '\n'):
                if str(message).startswith("@"):
                    self.add_message('[Secret]' + self.controller.prompt + message + '\n', "HotPink")
                else:
                    self.add_message('[You   ]' + self.controller.prompt + message + '\n', "CornflowerBlue")
            self.type_message_window.delete("1.0", tk.END)
        except Exception:
            print("\Exit command")

    def send_message_from__gui(self, event=None):
        try:
            message = self.type_message_window.get("1.0", tk.END + '-1c')
            if len(message) != 0 and message != '\n' and not str(message).isspace():
                if self.controller.send_message(message):
                    if str(message).startswith("@"):
                        self.add_message('[Secret]' + self.controller.prompt + message, "green")
                    else:
                        self.add_message('[Public]' + self.controller.prompt + message, "Black")
            self.type_message_window.delete("1.0", tk.END)
        except Exception:
            print("\Exit command")

    def logout(self, event=None):
        self.controller.__login = False
        self.controller.send_message("\exit")



    def add_message(self, new_message, color="black"):
        global downloadVar
        downloadVar = True
        self.controller.message_line += 1
        temp = "tag_" + str(self.controller.message_line)
        self.receive_message_window.tag_config(temp, foreground=color)
        self.receive_message_window.config(state=tk.NORMAL)
        self.receive_message_window.insert(tk.END, new_message, temp)
        self.receive_message_window.config(state=tk.DISABLED)
        self.receive_message_window.see(tk.END)

    def update_user_window(self, users):
        names = [name for name in str(users).split(" ") if name != ""]

        string_name = "Username: " + names[-1]
        self.chatroom_member_window['listvariable'] = tk.StringVar(value=names)

    def update_username(self, users):
        name_user = [name for name in str(users).split(" ") if name != ""]
        name_user_all = "Username: " + name_user[0].replace("0", " ")
        self.userName['textvariable'] = tk.StringVar(value=name_user_all)

    def get_name_for_secret(self, event=None):
        receiver_name = self.chatroom_member_window.get(self.chatroom_member_window.curselection())
        self.type_message_window.insert(tk.END, '@' + receiver_name + ' ')


if __name__ == '__main__':
    client = Client()
    client.title("5110 Common Room")
    client.iconbitmap('.\\chat.ico')
    client.mainloop()
