//
//  Connection.hpp
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/31.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

#ifndef Connection_hpp
#define Connection_hpp

#include <stdio.h>
#include <sys/socket.h>     // socket(), connect(), send(), recv()
#include <arpa/inet.h>      // sockaddr_in, inet_addr()
#include <stdlib.h>         // atoi()
#include <string.h>         // memset()
#include <unistd.h>         // close()

#define RECIEVE_BUFFER_SIZE 32          // 受信バッファサイズ

class Connection {

private:
    int sock;                                 // ソケットディスクリプタ
    struct sockaddr_in echoServerAddress;       // エコーサーバのアドレス
    unsigned short echoServerPort;              // エコーサーバのポート番号
    char    *serverIP;                          // サーバのIPアドレス（ドット10進数表記）
    char    *echoString;                        // エコーサーバに送信する文字列
    char    echoBuffer[RECIEVE_BUFFER_SIZE];    // エコー文字列用のバッファ
    unsigned int    echoStringLength;           // エコーする文字列のサイズ
    int bytesRecieved;                          // １回のrecv()で読み取られるバイト数
    int totalBytesRecieved;                     // １回のrecv()で読み取られる前バイト数

public:
    Connection();

    void execute(int argc, char *argv[]);

};

#endif /* Connection_hpp */
