//
//  HEViewController.h
//  HammerExample
//
//  Created by Tiago Bastos on 06/06/2012.
//  Copyright (c) 2012 Guilda. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HEViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *exampleTable;

- (IBAction)add:(id)sender;

@end
