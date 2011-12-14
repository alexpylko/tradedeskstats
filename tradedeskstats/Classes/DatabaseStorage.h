//
//  DatabaseStorage.h
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/23/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Account;

@interface DatabaseStorage : NSObject
{
    sqlite3 * connection;
}

@property (nonatomic, retain, readonly) NSMutableArray * accounts;

+(DatabaseStorage*) sharedDatabaseStorage;

-(NSInteger) insertAccount:(Account*) account;

-(Account*) accountWithName:(NSString*)name;

-(void) deleteAccount:(Account*) account;

@end
