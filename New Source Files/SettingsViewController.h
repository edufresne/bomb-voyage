//
//  SettingsViewController.h
//  Bomb Voyage
//
//  Created by Eric Dufresne on 2015-05-27.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <UIKit/UIKit.h>

//View controller that is reponsible for optionally switching between tap and tilt controls as well as deleting stored high score. Stores all of this items in NSUserDefaults

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sensitiityLabel;
@property (weak, nonatomic) IBOutlet UISlider *sensitivitySlider;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)sensitivityChanged:(id)sender;


@end
