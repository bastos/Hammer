//
//  HEViewController.m
//  HammerExample
//
//  Created by Tiago Bastos on 06/06/2012.
//  Copyright (c) 2012 Guilda. All rights reserved.
//

#import "HEViewController.h"
#import "HMRStore.h"

@interface HEViewController ()

@end

@implementation HEViewController
@synthesize exampleTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setExampleTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)add:(id)sender 
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d h:mm:s YYYY"];
    NSString *dateString = [dateFormat stringFromDate:date]; 
    
    [[HMRStore sharedInstance] pushValue:dateString toList:@"items" error:NULL];
    [self.exampleTable reloadData];
}

#pragma mark - Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[HMRStore sharedInstance] getValuesFromList:@"items" error:NULL] count];        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }

    cell.textLabel.text = [[[HMRStore sharedInstance] getValuesFromList:@"items" error:NULL] objectAtIndex:[indexPath row]]; 
    cell.textLabel.font = [UIFont systemFontOfSize:24.0f];            
    
    return cell;
}
@end
