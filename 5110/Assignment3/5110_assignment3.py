from socket import *
import sys  # In order to terminate the program

# Create a TCP/IP socket
serverSocket = socket(AF_INET, SOCK_STREAM)
# Prepare a sever socket

serverPort = 15000
BUFFER_SIZE = 1024
print('hostname is: ', gethostname())
# Bind the socket to server address and server port
serverSocket.bind(("", serverPort))

# Listen for incoming connections
serverSocket.listen(0)
while True:
    # Establish the connection
    print('Ready to serve...')
    connectionSocket, addr = serverSocket.accept()
    print('Connection address:', addr)

    try:
        message = connectionSocket.recv(BUFFER_SIZE)
        print('Message is: ', message)

        if len(message.split()) < 1:
            connectionSocket.close()
            print("++++++++++", message.split()[1])

        filename = message.split()[1]
        print('File name is: ', filename)

        f = open(filename[1:])
        outputdata = f.read()

        # Send one HTTP header line into socket
        connectionSocket.send("HTTP/1.1 200 OK\r\n\r\n".encode())

        # Send the content of the requested file to the client
        for i in range(0, len(outputdata)):
            connectionSocket.send(outputdata[i].encode())
        connectionSocket.send("\r\n".encode())

        connectionSocket.close()

    except IOError:
        # Send response message for file not found
        connectionSocket.send("HTTP/1.1 404 Not Found\r\n\r\n".encode())
        connectionSocket.send("<html><head></head><body><h1>404 Not Found</h1></body></html>\r\n".encode())

        # Close client socket
        connectionSocket.close()

serverSocket.close()

sys.exit()
# Terminate the program after sending the corresponding data
