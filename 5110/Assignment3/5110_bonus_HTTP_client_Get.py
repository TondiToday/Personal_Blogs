import socket

server = "127.0.0.1"
serverPort = 15000
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = (server, serverPort)
client.connect(server_address)

request_header = 'GET /index.html HTTP/1.1\r\nHost: localhost:15000\r\n\r\n'
client.send(request_header.encode())

response = ''
while True:
    message_rec = client.recv(1024)
    message = message_rec.decode()
    if not message_rec:
        break
    response += message

print(response)
client.close()
