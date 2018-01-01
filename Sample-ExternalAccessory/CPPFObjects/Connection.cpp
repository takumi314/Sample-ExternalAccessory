//
//  Connection.cpp
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/31.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

#include "Connection.hpp"

void DieWithError(char *errorMessage);  // エラー処理関数

void Connection::execute(int argc, char *argv[]) {
    int sock;                                 // ソケットディスクリプタ
    struct sockaddr_in echoServerAddress;       // エコーサーバのアドレス
    unsigned short echoServerPort;              // エコーサーバのポート番号
    char    *serverIP;                          // サーバのIPアドレス（ドット10進数表記）
    char    *echoString;                        // エコーサーバに送信する文字列
    char    echoBuffer[RECIEVE_BUFFER_SIZE];    // エコー文字列用のバッファ
    unsigned int    echoStringLength;           // エコーする文字列のサイズ
    int bytesRecieved;                          // １回のrecv()で読み取られるバイト数
    int totalBytesRecieved;                     // １回のrecv()で読み取られる前バイト数


    /**
     *  パラーメータの解析と正当性チェック
     */
    if (argc < 3 || 4 < argc) {
        fprintf(stderr, "Usage: %s <Server IP> <Echo Word> [<Echo Port>]\n", argv[0]);
        exit(1);
    }

    serverIP    = argv[1];      // サーバのIPアドレス（ドット10進数表記）
    echoString  = argv[2];      // エコー文字列

    if (argc == 4) {
        echoServerPort = atoi(argv[3]);     // 指定ポート番号があれば使用する
    } else {
        echoServerPort = 7;                 // エコーサービスのwell-known ポート番号
    }

    /**
     * TCPによる信頼性の高いストリームソケットを作成
     */
    if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
        DieWithError((char *)"socket() failed");
    }

    /**
     *  サーバのアドレス構造体を作成
     */
    memset(&echoServerAddress, 0, sizeof(echoServerAddress));   // 構造体に0を埋める
    echoServerAddress.sin_family = AF_INET;                     // インターネットアドレスファミリ
    echoServerAddress.sin_addr.s_addr = inet_addr(serverIP);    // サーバのIPアドレス
    echoServerAddress.sin_port = htons(echoServerPort);         // サーバのポート番号

    /**
     *  エコーサーバへの接続の確立
     */
    if (connect(sock, (struct sockaddr *) &echoServerAddress, sizeof(echoServerAddress)) < 0) {
        DieWithError((char *)"socket() failed");
    }

    // 入力データの長さを調べる
    echoStringLength = (unsigned)strlen(echoString);

    /**
     *  文字列をサーバに送信
     */
    if (send(sock, echoString, echoStringLength, 0) != echoStringLength) {
        DieWithError((char *)"send() sent a different number of bytes than expected");
    }

    /**
     *  同じ文字列をサーバから受信
     */
    totalBytesRecieved = 0;
    printf("Recieved");         // エコーされた文字列を表示するための準備

    while (totalBytesRecieved < echoStringLength) {
        /*
         バッファサイズに達するまでサーバからのデータを受信する (NULL文字用の1バイトを除く)
         */
        if ((bytesRecieved = (int)recv(sock, echoBuffer, RECIEVE_BUFFER_SIZE - 1, 0)) <= 0) {
            totalBytesRecieved += bytesRecieved;    // 総バイト数
            echoBuffer[bytesRecieved] = '\0';       // 文字列の終了
            printf("%s", echoBuffer);                     // エコーバッファの表示
        }

    }

    printf("\n");

    close(sock);
    exit(0);
}

void DieWithError(char *errorMessage) {
    perror(errorMessage);
    exit(1);
}


