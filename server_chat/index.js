const app = require('express')()
const http = require('http').createServer(app)
const io = require('socket.io')(http);

app.get('/', (req, res) => {
    res.send("Node Server is running. Yay!!")
})

io.on('connection', socket => {
    //Get the chatID of the user and join in a room of the same chatID
    chatID = socket.handshake.query.chatID
    socket.join(chatID)

    //Leave the room if the user closes the socket
    socket.on('disconnect', () => {
        socket.leave(chatID)
    })

    //Send message to only a particular user
    socket.on('send_message', message => {
        receiverChatID = message.receiverChatID
        senderChatID = message.senderChatID
        content = message.content
		
		console.log('senderChatID:'+senderChatID +' & receiverChatID: '+receiverChatID+' & content:'+content);

        //Send message to only that particular room
        socket.in(receiverChatID).emit('receive_message', {
            'content': content,
            'senderChatID': senderChatID,
            'receiverChatID':receiverChatID,
        })
    })
	socket.on('typing', message => {
        receiverChatID = message.receiverChatID
        senderChatID = message.senderChatID
       
		console.log(senderChatID +'typing ');

        //Send message to only that particular room
        socket.in(receiverChatID).emit('typing', {
            'senderChatID': senderChatID,
            'receiverChatID':receiverChatID,
        })
    })
	socket.on('stop_typing',message=> {
		//Send message to only that particular room
		console.log(senderChatID +'stop_typing ');
        socket.in(receiverChatID).emit('stop_typing', {
            'senderChatID': senderChatID,
            'receiverChatID':receiverChatID,
        })
    });
});

const PORT = process.env.PORT || 5000;

http.listen(PORT,()=>{
	console.log('Server runing at Port '+PORT);
});