//
//  HMRStoreTests.m
//  HMRStoreTests
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 GUILDA TECNOLOGIA. All rights reserved.
//

#import "HMRStoreTests.h"
#import "HMRStore.h"

@implementation HMRStoreTests

@synthesize databasePath;

- (void)setUp
{
    [super setUp];

    self.databasePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HammerStore" ofType:@"sqlite"];
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
 
    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO STORE (UUID, KEY, CONTENT) VALUES ('%@', '%@', '%@')", @"e54e59e0-aa6d-11e1-afa6-0800200c9a66", @"test", @"123" ];
    
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
    [store setValue:@"bar" forKey:@"foo" error:&error];
    
    STAssertTrue(error == NULL, @"Should not have an error");
}

- (void)testSetObject
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    NSError *error = NULL;
    [store setValue:[[NSObject alloc] init] forKey:@"foo" error:&error];
    
    STAssertTrue(error == NULL, @"Should not have an error");
}


- (void)testGet
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store setValue:@"bar" forKey:@"foo" error:NULL];
    NSString *value = [store valueForKey:@"foo" error:NULL];
    NSLog(@"Value == %@", value);
    
    STAssertTrue([value isEqualToString:@"bar"], @"Value wasn't retrieved ");
}

- (void)testRemove
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store setValue:@"bar" forKey:@"foo" error:NULL];
    [store removeValueForKey:@"foo" error:NULL];
    id value = [store valueForKey:@"foo" error:NULL];
    
    STAssertTrue(value == NULL, @"Item was not deleted");
}

- (void)testInvalidNullKey
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    NSError *error;
    [store setValue:@"bar" forKey:NULL error:&error];    
    
    STAssertTrue(error != NULL, @"Key was not invalid");    
}

- (void)testInvalidEmptyStringKey
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    NSError *error;
    [store setValue:@"bar" forKey:@"" error:&error];    
    
    STAssertTrue(error != NULL, @"Key was not invalid");    
}

- (void)testPushAndGetAllValuesFromList
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store pushValue:@"1" toList:@"foo" error:NULL];
    [store pushValue:@"2" toList:@"foo" error:NULL];    
    id object0 = [[store getValuesFromList:@"foo" error:NULL] objectAtIndex:0];
    id object1 = [[store getValuesFromList:@"foo" error:NULL] objectAtIndex:1];    
    
    STAssertTrue([object0 isEqualToString:@"1"], @"The first object is not 0");
    STAssertTrue([object1 isEqualToString:@"2"], @"The first object is not 1");    
}


- (void)testPopValueFromList 
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store pushValue:@"1" toList:@"testPopValueFromList" error:NULL];
    [store pushValue:@"2" toList:@"testPopValueFromList" error:NULL];    
    
    id object0 = [store popValueFromList:@"testPopValueFromList" error:NULL];
    id object1 = [store popValueFromList:@"testPopValueFromList" error:NULL];    
        
    STAssertTrue([object0 isEqualToString:@"2"], @"Objects removed from list");    
    STAssertTrue([object1 isEqualToString:@"1"], @"Objects removed from list");        
    STAssertTrue([[store getValuesFromList:@"testPopValueFromList" error:NULL] count] == 0, @"Objects removed from list");
}

- (void)testShiftValueFromList 
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store pushValue:@"1" toList:@"testPopValueFromList" error:NULL];
    [store pushValue:@"2" toList:@"testPopValueFromList" error:NULL];    
    
    id object0 = [store shiftValueFromList:@"testPopValueFromList" error:NULL];
    id object1 = [store shiftValueFromList:@"testPopValueFromList" error:NULL];    
    
    STAssertTrue([object0 isEqualToString:@"1"], @"Objects removed from list");    
    STAssertTrue([object1 isEqualToString:@"2"], @"Objects removed from list");        
    STAssertTrue([[store getValuesFromList:@"testPopValueFromList" error:NULL] count] == 0, @"Objects removed from list");
}

- (void)testRemoveValueFromList 
{
    HMRStore *store = [HMRStore sharedInstanceWithDatabasePath:self.databasePath];
    [store pushValue:@"1" toList:@"testPopValueFromList" error:NULL];
    [store pushValue:@"2" toList:@"testPopValueFromList" error:NULL];    
    
    [store removeListForKey:@"testPopValueFromList" error:NULL];
    
    STAssertTrue([[store getValuesFromList:@"testPopValueFromList" error:NULL] count] == 0, @"Objects removed from list");
}

@end
