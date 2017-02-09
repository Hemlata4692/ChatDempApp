//
//  DataAwareTurnSocket.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TURNSocket.h"
@interface DataAwareTurnSocket : TURNSocket {
    NSData *dataToSend;
}

@property (nonatomic, readwrite) NSData *dataToSend;

@end
