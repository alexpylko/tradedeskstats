//
//  DatabaseStorage.m
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/23/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import "DatabaseStorage.h"
#import "Account.h"

@implementation DatabaseStorage

@synthesize accounts;

static DatabaseStorage * gDatabaseStorage = nil;

+(DatabaseStorage*) sharedDatabaseStorage;
{
    if ( nil == gDatabaseStorage ) 
    {
        gDatabaseStorage = [[DatabaseStorage alloc] init];
    }
    return gDatabaseStorage;
}

-(NSMutableArray*)accounts;
{
    NSMutableArray * list = [NSMutableArray array];
    
    NSString * query = @"SELECT * FROM accounts";
    
    sqlite3_stmt * stmt = NULL;
    if ( SQLITE_OK == sqlite3_prepare_v2( connection, [query UTF8String], -1, & stmt, NULL ) )
    {
        while ( sqlite3_step( stmt ) == SQLITE_ROW )
        {
            int uniqueId = sqlite3_column_int( stmt, 0 );
            char * name = (char *) sqlite3_column_text( stmt, 1 );
            char * dateString = (char *) sqlite3_column_text( stmt, 2 );
        
            if( NULL != name )
            {
                Account * account = [[Account alloc] initWithUniqueId:uniqueId name:[NSString stringWithUTF8String:name] dateString:[NSString stringWithUTF8String:dateString]];
                [list addObject:account];
                [account release];
            }
        }

        sqlite3_finalize( stmt );
    }
    
    return list;
}

-(NSInteger) insertAccount:(Account*) account;
{
    NSInteger result = -1;
    
    NSString * query = [NSString stringWithFormat:@"INSERT INTO accounts(name, added) VALUES('%@', '%@')", account.name, account.dateString];
    
    char * error = NULL;
    if( SQLITE_OK == sqlite3_exec( connection, [query UTF8String], NULL, NULL, & error ) )
    {
        result = sqlite3_last_insert_rowid( connection );
        account.uniqueId = result;
    }
    else
    {
        sqlite3_free( error );
    }
    
    return result;
}

-(Account*) accountWithName:(NSString*)name;
{
    Account * account = [[[Account alloc] initWithName:name] autorelease];
    
    [self insertAccount:account];
    
    return account;
}

-(void) deleteAccount:(Account*) account;
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM accounts WHERE id = %d", account.uniqueId ];
    
    char * error = NULL;
    if( SQLITE_OK != sqlite3_exec( connection, [query UTF8String], NULL, NULL, & error ) )
    {
        sqlite3_free( error );
    }
}

- (id)init 
{
    if ( ( self = [super init] ) ) 
    {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
        NSString * appDirectory = [paths objectAtIndex:0];
        NSString * targetPath = [appDirectory stringByAppendingPathComponent:@"tradedeskstats.sqlite3"];
        
        if ( !( [fileManager fileExistsAtPath:targetPath] ) ) 
        {
            NSError * error = nil;
            NSString * defaultPath = [[NSBundle mainBundle] pathForResource:@"tradedeskstats" 
                                                              ofType:@"sqlite3"];
            [fileManager copyItemAtPath:defaultPath toPath:targetPath error:&error];
        }
    
        if ( SQLITE_OK != sqlite3_open( [targetPath UTF8String], & connection ) )
        {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc 
{
    sqlite3_close( connection );
    [super dealloc];
}

@end
