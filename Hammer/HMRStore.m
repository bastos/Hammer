//
//  HMRStore.m
//  HMRStore
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 GUILDA TECNOLOGIA. All rights reserved.
//

#import "HMRStore.h"

NSInteger const HMRStoreKVType = 0;
NSInteger const HMRStoreListType = 1;

@interface HMRStore ()

- (NSArray*)HMR_getValuesForKey:(NSString *)key error:(NSError**)error;
- (void)HMR_saveValue:(NSString*)value forKey:(NSString*)key kind:(int)kind error:(NSError **)error;
- (void)HMR_removeValueUsingUUID:(NSString *)uuid error:(NSError**)error;
- (void)HMR_removeValueForKey:(NSString *)key error:(NSError**)error;

@end


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
            const char *sqlStatement = "CREATE TABLE IF NOT EXISTS STORE (ID INTEGER PRIMARY KEY AUTOINCREMENT, UUID TEXT, TIMESTAMP INTEGER, KEY TEXT, CONTENT TEXT, KIND INTEGER)";
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

#pragma mark - Lists

- (void)pushValue:(id)value toList:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return;
    }    
    
    [self HMR_saveValue:value forKey:key kind:HMRStoreListType error:error];
}

- (id)popValueFromList:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return NULL;
    }
    
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT CONTENT, UUID FROM STORE WHERE KEY = '%@' AND KIND = %d ORDER BY TIMESTAMP DESC LIMIT 1", key, HMRStoreListType];
    
    NSLog(@"QUERY %@", queryStatement);
    
    sqlite3_stmt *statement;
    id content = NULL;
    
    if (sqlite3_prepare_v2(_databaseHandle, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            content = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
            [self HMR_removeValueUsingUUID: [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)] error: error];
        }
        sqlite3_finalize(statement);
    } else if (error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
        NSLog(@"Prepare does not work: %@", queryStatement);        
        return NULL;
    }
    
    return content;       
}

- (id)shiftValueFromList:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return NULL;
    }
    
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT CONTENT, UUID FROM STORE WHERE KEY = '%@' AND KIND = %d ORDER BY TIMESTAMP ASC LIMIT 1", key, HMRStoreListType];
    sqlite3_stmt *statement;
    id content = NULL;
    
    if (sqlite3_prepare_v2(_databaseHandle, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            content = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
            [self HMR_removeValueUsingUUID: [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)] error: error];
        }
        sqlite3_finalize(statement);
    } else if (error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
        NSLog(@"Prepare does not work: %@", queryStatement);        
        return NULL;
    }
    
    return content;       
}

- (NSArray *)getValuesFromList:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return NULL;
    }    
    
    return [self HMR_getValuesForKey:key error:error];
}

- (void)removeListForKey:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return;
    }   
    
    [self HMR_removeValueForKey:key error:error];
}


#pragma mark - Key/Value

- (void)getValue:(id)value forKey:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return;
    }    
    
    if ([self valueForKey:key error:NULL] != NULL) {
        [self removeValueForKey:key error:NULL];
    }
    
    [self HMR_saveValue:value forKey:key kind:HMRStoreKVType error:error];
}

- (id)valueForKey:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return NULL;
    }    
    
    NSArray *values = [self HMR_getValuesForKey:key error:error];

    if ([values count] == 0) {
        return NULL;
    }
    
    return [values objectAtIndex:0];
}

- (void)removeValueForKey:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return;
    }    
    
    [self HMR_removeValueForKey:key error:error];
}

#pragma mark - Validations

- (BOOL)validKey:(NSString *)key error:(NSError**)error
{
    if ((key == NULL || [key isEqualToString:@""]) && error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Key is invalid" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        return false;
    }  else {
        return true;
    }
}

#pragma mark - Private methods

- (NSArray*)HMR_getValuesForKey:(NSString *)key error:(NSError**)error
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT CONTENT FROM STORE WHERE KEY = '%@' ORDER BY TIMESTAMP", key];

    sqlite3_stmt *statement;

    NSMutableArray *content = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(_databaseHandle, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [content addObject: [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)]];
        }
        sqlite3_finalize(statement);
    } else if (error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
        NSLog(@"Prepare does not work: %@", queryStatement);        
        return NULL;
    }

    return content;
}

- (void)HMR_removeValueUsingUUID:(NSString *)uuid error:(NSError**)error
{
    NSString *deleteStatement = [NSString stringWithFormat:@"DELETE FROM STORE WHERE UUID = '%@' ", uuid];
    sqlite3_stmt *statement;
    
    NSLog(@"Executing: %@", deleteStatement);
    
    if (sqlite3_prepare_v2(_databaseHandle, [deleteStatement UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        char *execError;
        
        if (sqlite3_exec(_databaseHandle, [deleteStatement UTF8String], NULL, NULL, &execError) == SQLITE_OK)
        {
            NSLog(@"Data Deleted");
        } else if (error) {
            NSMutableDictionary *errorDetail = [[NSMutableDictionary alloc] init];
            [errorDetail setValue:@"Failed to exec statement" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        }
        sqlite3_finalize(statement);
    } else if (error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
        NSLog(@"Prepare does not work: %@", deleteStatement);        
    } else {
        NSLog(@"Prepare does not work: %@", deleteStatement);        
    }
}

- (void)HMR_saveValue:(NSString*)value forKey:(NSString*)key kind:(NSInteger)kind error:(NSError **)error
{
    if (![self validKey:key error:error]) {
        return;
    }    
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));     
    
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO STORE (UUID, KEY, CONTENT, TIMESTAMP, KIND) VALUES ('%@', '%@', '%@', %f, %d)", uuidString, key, value, [[NSDate date] timeIntervalSince1970], kind];
    NSLog(@"QUERY %@", insertStatement);
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_databaseHandle, [insertStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        char *execError;

        if (sqlite3_exec(_databaseHandle, [insertStatement UTF8String], NULL, NULL, &execError) == SQLITE_OK)
        {
            NSLog(@"Data inserted");
        } else if (error) {
            NSMutableDictionary *errorDetail = [[NSMutableDictionary alloc] init];
            [errorDetail setValue:@"Failed to exec statement" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        }
        sqlite3_finalize(statement);
    } else if (error) { 
        NSMutableDictionary *errorDetail = [[NSMutableDictionary alloc] init];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
    }  
}

- (void)HMR_removeValueForKey:(NSString *)key error:(NSError**)error
{
    if (![self validKey:key error:error]) {
        return;
    }    
        
    NSString *insertStatement = [NSString stringWithFormat:@"DELETE FROM STORE WHERE KEY = '%@'", key];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_databaseHandle, [insertStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        char *execError;
        if (sqlite3_exec(_databaseHandle, [insertStatement UTF8String], NULL, NULL, &execError) == SQLITE_OK)
        {
            NSLog(@"Data Deleted");
        } else if (error) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to exec statement" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Guilda.Hammer" code:0 userInfo: errorDetail];
        }
        sqlite3_finalize(statement);
    } else if (error) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to prepare statement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Guilda.Hammer" code:1 userInfo: errorDetail];        
    }
}

- (void)dealloc {
    sqlite3_close(_databaseHandle);
}
@end
