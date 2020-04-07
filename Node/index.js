const DISCORD = false;
const EMAIL = '';
const PASSWORD = '';

const express = require('express');
const app = express();
const http = require('http').Server(app);
const fs = require('fs');
const Lbl = require('line-by-line');

const Discord = require('discord.js');
const client = new Discord.Client();

let readyDone = false;

if (DISCORD) {
    client.on('ready', () => {
        if (!readyDone) {
            readyDone = true;
            console.log(client.user.presence);
            client.user.setPresence({status: 'online', game: {name: 'Selecting a song ...', type: 0}}).then(() => {
                console.log('Discord ready !');
                console.log(client.user.presence);
            });
        }
    });
    client.login(EMAIL, PASSWORD).then(token => {
        console.log(token);
        console.log(client.user.presence);
    }).catch(error => {
        console.log(error);
    });
}

setInterval(() => {
    if (s) {
        let songInfos = [];
        let lr = new Lbl('songinfos.txt');
        lr.on('line', line => {
            songInfos.push(line);
        });
        lr.on('end', () => {
            s.emit('songinfos', songInfos);
        });
    }
}, 2000);

let s;

app.use('/files', express.static('files'));
http.listen(8080);

let io = require('socket.io').listen(http);

io.sockets.on('connect', socket => {
    console.log('yay');
    s = socket;
    if (DISCORD) {
        s.on('game', data => {
            if (data == '') {
                if (client.user)
                    client.user.setPresence({status: 'online', game: {name: 'Selecting a song ...', type: 0}}).then(() => {
                        console.log(client.user.presence);
                    });
            } else {
                if (client.user)
                    client.user.setPresence({status: 'online', game: {name: data, type: 0}}).then(() => {
                        console.log(client.user.presence);
                    });
            }
        });
    }
});

io.sockets.on('disconnect', msg => {
    console.log('noo');
    s = false;
});
