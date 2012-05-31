//
//  HammerTests.m
//  HammerTests
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 Guilda. All rights reserved.
//

#import "HRMStoreTests.h"
#import "HMRStore.h"

@implementation HRMStoreTests

@synthesize databasePath;

- (void)setUp
{
    [super setUp];
    
    self.databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HammerStore.sqlite"];        
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    
    [store setupDatabase];
}

- (void)tearDown
{
    [[[NSFileManager alloc] init] removeItemAtPath:self.databasePath error:NULL];

    [super tearDown];
}

- (void)testSingleton
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    
    STAssertNotNil(store, @"Shared instance is nil");
}

- (void)testCreateDatabase
{    
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    
    sqlite3 *databaseHandle = [store databaseHandle];
 
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO STORE (UUID, KEY, CONTENT) VALUES (?, ?, ?)", @"e54e59e0-aa6d-11e1-afa6-0800200c9a66", @"test", @"123" ];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(databaseHandle, [insertStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        char *error;
        if (sqlite3_exec(databaseHandle, [insertStatement UTF8String], NULL, NULL, &error) == SQLITE_OK)
        {
            STAssertTrue(error==NULL, @"Insert doesn't work");
        } else {
            STFail(@"Insert doesn't work");
        }
        sqlite3_finalize(statement);
    } else {
        STFail(@"Prepare doesn't work");
    }
}

- (void)testSet
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    NSError *error = NULL;
    
    [store value:@"bar" forKey:@"foo" error:&error];
    STAssertTrue(error == NULL, @"Should not have an error");
}

- (void)testGet
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];

    [store value:@"bar" forKey:@"foo" error:NULL];
    
    NSString *value = [store valueForKey:@"foo" error:NULL];
    
    NSLog(@"Value == %@", value);
    
    STAssertTrue([value isEqualToString:@"bar"], @"Value wans't retrieved ");
}

- (void)testeDelete
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store value:@"bar" forKey:@"foo" error:NULL];
    [store deleteValueForKey:@"foo" error:NULL];
    id value = [store valueForKey:@"foo" error:NULL];
    STAssertTrue(value == NULL, @"Item was not deleted");
}

@end
