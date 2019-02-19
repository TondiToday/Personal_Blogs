import socket

server = "127.0.0.1"
serverPort = 15000

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((server, serverPort))
client.sendall(bytes("+++ This is from Client +++", 'UTF-8'))

while True:
    message_rec = client.recv(1024)
    print("Message From Server : '", message_rec.decode(), "'")

    input_message = input()
    client.sendall(bytes(input_message, 'UTF-8'))

    if input_message == 'close':
        break
client.close()
