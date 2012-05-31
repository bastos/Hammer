//
//  HMRStore.m
//  HMRStore
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 Guilda. All rights reserved.
//

#import "HMRStore.h"

@implementation HMRStore

@synthesize databaseHandle = _databaseHandle;
@synthesize databasePath = _databasePath;

static HMRStore *sharedSingleton;
static BOOL initialized = NO;

+ (HMRStore*)sharedInstanceWithDatabasePath:(NSString*)databasePath
{
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[HMRStore alloc] init];
        
        sharedSingleton.databasePath = databasePath;
        
        [sharedSingleton setupDatabase];
    }
    
    return sharedSingleton;
}

+ (HMRStore*)sharedInstance
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"HammerStore.db"];
    
    return [self sharedInstanceWithDatabasePath:databasePath];
}

- (void)setupDatabase
{
    
    bool databaseAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:self.databasePath];
    
    if (sqlite3_open([self.databasePath UTF8String], &_databaseHandle) == SQLITE_OK) {
        if (!databaseAlreadyExists) {
            const char *sqlStatement = "CREATE TABLE IF NOT EXISTS STORE (ID INTEGER PRIMARY KEY AUTOINCREMENT, UUID TEXT, KEY TEXT, CONTENT TEXT)";
            char *error;
            if (sqlite3_exec((_databaseHandle), sqlStatement, NULL, NULL, &error) == SQLITE_OK) {
                NSLog(@"Database and tables created. %@", self.databasePath);
            } else {
                NSLog(@"Error creating table: %s", error);
            }
        }
    } else {
        NSLog(@"Failed to open the database %@", self.databasePath);
        sqlite3_close((_databaseHandle));
    }
}

- (void)value:(id)value forKey:(NSString *)key error:(NSError**)error
{
    if ([self valueForKey:key error:NULL] != NULL) {
        [self deleteValueForKey:key error:NULL];
    }

    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));     
    
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO STORE (UUID, KEY, CONTENT) VALUES ('%@', '%@', '%@')", uuidString, key, value];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_databaseHandle, [insertStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        char *execError;
        if (sqlite3_exec(_databaseHandle, [insertStatement UTF8String], NULL, NULL, &execError) == SQLITE_OK)
        {
            NSLog(@"Data inserted");
        } else {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to exec statement" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        }
        sqlite3_finalize(statement);
    } else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
    }  
}

- (id)valueForKey:(NSString *)key error:(NSError**)error
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT CONTENT FROM STORE WHERE KEY = '%@'", key];
    
    sqlite3_stmt *statement;
    
    id content = NULL;
    
    if (sqlite3_prepare_v2(_databaseHandle, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            content = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
        }
        sqlite3_finalize(statement);
    } else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
        NSLog(@"Prepare does not work: %@", queryStatement);        
        return NULL;
    }
    
    return content;
}

- (void)deleteValueForKey:(NSString *)key error:(NSError**)error
{
    NSString *insertStatement = [NSString stringWithFormat:@"DELETE FROM STORE WHERE KEY = '%@'", key];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_databaseHandle, [insertStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        char *execError;
        if (sqlite3_exec(_databaseHandle, [insertStatement UTF8String], NULL, NULL, &execError) == SQLITE_OK)
        {
            NSLog(@"Data Deleted");
        } else {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to exec statement" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        }
        sqlite3_finalize(statement);
    } else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
    }      
}

- (void)dealloc {
    sqlite3_close(_databaseHandle);
}
@end
