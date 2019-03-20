import socket

server = '192.168.1.110'
serverPort = 64001
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = (server, serverPort)
client.connect(server_address)

print('Enter your request:')
request_header = input()
# GET csv /Sales.csv 0001 3 3
# request_header = 'GET csv /Sales.csv 0001 5 5 HTTP/1.1\r\nHost: localhost:64001\r\n\r\n'
client.send(request_header.encode())

response = ''
while True:
    message_rec = client.recv(1024)
    if not message_rec:
        break
    message = message_rec.decode()
    response += message

print(response)
client.close()
