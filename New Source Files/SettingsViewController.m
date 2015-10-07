//
//  SettingsViewController.m
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2015-05-27.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) NSArray *headerNames;
@property BOOL tiltControls;
@end

@implementation SettingsViewController
#pragma mark - Initialization

-(void)viewDidLoad{
    [super viewDidLoad];
    //Customizes navigation controller
    UIColor *color = [SettingsViewController colorWithR:0 G:122 B:255];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[SettingsViewController colorWithR:0 G:9 B:173], NSForegroundColorAttributeName, nil]];
    // Head names for sections as well as retrieves current tilt options
    self.headerNames = [NSArray arrayWithObjects:@"Controls", @"Options", nil];
    self.tiltControls = [[NSUserDefaults standardUserDefaults] boolForKey:@"tiltControls"];
}
// Hide status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark - TableView Data Source
//Number of rows. Adds extra row for sensitivity if tilt controls are selected
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        if (self.tiltControls)
            return 3;
        else
            return 2;
    }
    else
        return 1;
}
#pragma mark - Table View Delegate
//Custom UIView for section headers
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Heiti SC Medium" size:12.0]];
    [label setText:self.headerNames[section]];
    [label setTextColor:[UIColor blueColor]];
    [view addSubview:label];
    return view;
}
//Change defaults if items are changed. If user selects to delete high score data a confirming UIAlertView is shown
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if (indexPath.row == 0){
            self.tiltControls = NO;
            [self.tableView reloadData];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            NSArray *array = cell.contentView.subviews;
            for (UIView *view in array){
                view.alpha = 0.5;
                if ([view.class isSubclassOfClass:[UIImageView class]])
                    view.alpha = 0;
            }
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            array = cell.contentView.subviews;
            for (UIView *view in array){
                view.alpha = 1;
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tiltControls"];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tiltControls"];
            self.tiltControls = YES;
            [self.tableView reloadData];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            NSArray *array = cell.contentView.subviews;
            for (UIView *view in array){
                view.alpha = 0.5;
                if ([view.class isSubclassOfClass:[UIImageView class]])
                    view.alpha = 0;
            }
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            array = cell.contentView.subviews;
            for (UIView *view in array){
                view.alpha = 1;
            }
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear High Score?" message:@"Type \"delete\" to confirm. This cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;
        [alert show];
    }
}
//Customizes cell based on current selection. Fades all items in view to half alpha if not selected.
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && self.tiltControls && indexPath.section == 0){
        NSArray *array = cell.contentView.subviews;
        for (UIView *view in array){
            view.alpha = 0.5;
            if ([view.class isSubclassOfClass:[UIImageView class]])
                view.alpha = 0;
        }
    }
    else if (indexPath.row == 1 && !self.tiltControls && indexPath.section == 0){
        NSArray *array = cell.contentView.subviews;
        for (UIView *view in array){
            view.alpha = 0.5;
            if ([view.class isSubclassOfClass:[UIImageView class]])
                view.alpha = 0;
        }
    }
    else if (indexPath.row == 2 && indexPath.section == 0){
        //Changes sensitivity based on level of 1 to 5
        int sensitivity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"sensitivity"];
        if (sensitivity<1||sensitivity>5){
            sensitivity = 3;
            [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"sensitivity"];
        }
        self.sensitivitySlider.value = sensitivity;
        NSString *suffix = @"";
        if (sensitivity<3)
            suffix = @"(Low)";
        else if (sensitivity==3)
            suffix = @"(Default)";
        else
            suffix = @"(High)";
        self.sensitiityLabel.text = [NSString stringWithFormat:@"%i %@", sensitivity, suffix];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
#pragma mark - Navigation and Helper Methods
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sensitivityChanged:(id)sender {
    int sensitivity = (int)self.sensitivitySlider.value;
    NSString *suffix = @"";
    if (sensitivity<3)
        suffix = @"(Low)";
    else if (sensitivity==3)
        suffix = @"(Default)";
    else
        suffix = @"(High)";
    self.sensitiityLabel.text = [NSString stringWithFormat:@"%i %@", sensitivity, suffix];
    [[NSUserDefaults standardUserDefaults] setInteger:sensitivity forKey:@"sensitivity"];
}
// Helper method for color creation using integers instead of floats
+(UIColor*)colorWithR:(NSUInteger)r G:(NSUInteger)g B:(NSUInteger)b{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}
#pragma Alert View Delegate
//User must type delete in textfield to confirm high score erase.
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0&&buttonIndex == 1){
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text isEqualToString:@"delete"]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"highScore"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful" message:@"High Score Cleared" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            alert.tag = -1;
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not Clear High Score" message:@"Entry Error" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
            alert.tag = 1;
            [alert show];
        }
    }
    else if (alertView.tag == 1&& buttonIndex == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear High Score?" message:@"Type \"delete\" to confirm. This cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;
        [alert show];
    }
}
@end
