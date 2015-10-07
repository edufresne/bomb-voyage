//
//  StoreViewController.m
//  Store
//
//  Created by Eric Dufresne on 2015-03-24.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import "StoreViewController.h"
#import "PassiveTableViewCell.h"
#import "SkinTableViewCell.h"
#import "AppDelegate.h"
//Instance Variables and Properties
@interface StoreViewController ()
{
    BOOL purchasing;
}
@property (strong, nonatomic) NSArray *headerNames;
@property (assign, nonatomic) NSInteger coinPurse;
@end

@implementation StoreViewController
//Initialize all data and retrieve all data from core Data, split into arrays. If store has never been called before then all the values are initialized and saved in the context
- (void)viewDidLoad {
    [super viewDidLoad];
    purchasing = NO;
    // Customize color values of navigation bar//
    UIColor *color = [StoreViewController colorWithR:0 G:122 B:255];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[StoreViewController colorWithR:0 G:9 B:173], NSForegroundColorAttributeName, nil]];
    
    //Getting coin amount from user defaults and setting title
    self.coinPurse = [[NSUserDefaults standardUserDefaults]integerForKey:@"coinPurse"];
    self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
    
    //Array intiaialization and headers//
    self.headerNames = [NSArray arrayWithObjects:@"Skins", @"Upgrades (Passive)", @"Powerups", @"Purchase More Coins", nil];
    self.passives = [[NSMutableArray alloc] init];
    self.purchases = [[NSMutableArray alloc] init];
    self.powerups = [[NSMutableArray alloc] init];
    self.skins = [[NSMutableArray alloc] init];
    
    //See if store has been shown before
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL initialized = [defaults boolForKey:@"initialized"];
    if (!initialized){
        initialized = YES;
        [defaults setBool:initialized forKey:@"initialized"];
        [defaults setBool:NO forKey:@"shared"];
        
        // Initialize all objects with prices of tiers, escriptions and names, save all to the context and add to array after
        BVTierProduct *cheatDeath = [[BVTierProduct alloc] initWithIdentifier:@"cheatDeath"];
        [cheatDeath setName:@"Cheat Death"];
        [cheatDeath setPrices:[NSMutableArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:250], [NSNumber numberWithUnsignedInteger:500], [NSNumber numberWithUnsignedInteger:1000], [NSNumber numberWithUnsignedInteger:2000], nil]];
        [cheatDeath setDescriptions:[NSMutableArray arrayWithObjects:@"15% Chance to absorb a collided bomb", @"25% Chance to absorb a collided bomb", @"35% Chance to absorb a collided bomb", @"45% Chance to absorb a collided bomb", nil]];
        [cheatDeath save];
        [self.passives addObject:cheatDeath];
        
        BVTierProduct *moneyMaker = [[BVTierProduct alloc] initWithIdentifier:@"moneyMaker"];
        [moneyMaker setName:@"Money Maker"];
        [moneyMaker setPrices:[NSMutableArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:250], [NSNumber numberWithUnsignedInteger:500], [NSNumber numberWithUnsignedInteger:1250], [NSNumber numberWithUnsignedInteger:2250], nil]];
        [moneyMaker setDescriptions:[NSMutableArray arrayWithObjects:@"5% Chance a coin is worth 2 instead of 1", @"10% Chance a coin is worth 3 instead of 1", @"%15 Chance a coin is worth 4 instead of 1", @"20% Chance a coin is worth 5 instead of 1", nil]];
        [moneyMaker save];
        [self.passives addObject:moneyMaker];
        
        BVTierProduct *powerupMaster = [[BVTierProduct alloc] initWithIdentifier:@"powerMaster"];
        [powerupMaster setName:@"Power Master"];
        [powerupMaster setPrices:[NSMutableArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:250], [NSNumber numberWithUnsignedInteger:500], [NSNumber numberWithUnsignedInteger:1000], [NSNumber numberWithUnsignedInteger:2000], nil]];
        [powerupMaster setDescriptions:[NSMutableArray arrayWithObjects:@"Powerups last an extra 2 seconds", @"Powerups last an extra 4 seconds", @"Powerups last an extra 6 seconds", @"Powerups last an extra 8 seconds", nil]];
        [powerupMaster save];
        [self.passives addObject:powerupMaster];
        BVSkinProduct *normalSkin = [[BVSkinProduct alloc] initWithIdentifier:@"normalSkin"];
        [normalSkin setName:@"Default Skin"];
        [normalSkin setPrice:0];
        [normalSkin setPurchased:YES];
        [normalSkin setProductDescription:@"Default Skin"];
        [normalSkin save];
        [[NSUserDefaults standardUserDefaults] setObject:normalSkin.identifier forKey:@"selectedSkin"];
        [self.skins addObject:normalSkin];
        
        BVSkinProduct *beastModeSkin = [[BVSkinProduct alloc] initWithIdentifier:@"beastModeSkin"];
        [beastModeSkin setName:@"Beast Mode Skin"];
        [beastModeSkin setPrice:125];
        [beastModeSkin setProductDescription:@"A more athletic looking skin"];
        [beastModeSkin save];
        [self.skins addObject:beastModeSkin];
        
        BVSkinProduct *ninjaSkin = [[BVSkinProduct alloc] initWithIdentifier:@"ninjaSkin"];
        [ninjaSkin setName:@"Ninja Skin"];
        [ninjaSkin setPrice:125];
        [ninjaSkin setProductDescription:@"A stealthy looking skin"];
        [ninjaSkin save];
        [self.skins addObject:ninjaSkin];
        
        BVSkinProduct *jackpot = [[BVSkinProduct alloc] initWithIdentifier:@"jackpot"];
        [jackpot setName:@"Jackpot"];
        [jackpot setPrice:1000];
        [jackpot setProductDescription:@"Spawn only coins for 4 seconds"];
        [jackpot save];
        [self.powerups addObject:jackpot];
        
        BVSkinProduct *fastReflexes = [[BVSkinProduct alloc] initWithIdentifier:@"fastReflexes"];
        [fastReflexes setName:@"Fast Reflexes"];
        [fastReflexes setPrice:1000];
        [fastReflexes setProductDescription:@"Slows down time for 10 seconds"];
        [fastReflexes save];
        [self.powerups addObject:fastReflexes];
        
        BVSkinProduct *invincible = [[BVSkinProduct alloc] initWithIdentifier:@"invincibility"];
        [invincible setName:@"Invincibility"];
        [invincible setPrice:1000];
        [invincible setProductDescription:@"Immune to all bombs for 5 seconds"];
        [invincible save];
        [self.powerups addObject:invincible];
        
        // In app purchases
        BVConversionProduct *coins1 = [[BVConversionProduct alloc] initWithIdentifier:@"BombVoyage.500Coin"];
        [coins1 setName:@"500 Coins"];
        [coins1 setCoinValue:500];
        [coins1 setCashValue:0.99];
        [coins1 save];
        [self.purchases addObject:coins1];
        
        BVConversionProduct *coins2 = [[BVConversionProduct alloc] initWithIdentifier:@"BombVoyage.1500Coin"];
        [coins2 setName:@"1500 Coins"];
        [coins2 setCoinValue:1500];
        [coins2 setCashValue:2.99];
        [coins2 save];
        [self.purchases addObject:coins2];
        
        BVConversionProduct *coins3 = [[BVConversionProduct alloc] initWithIdentifier:@"BombVoyage.2500Coin"];
        [coins3 setName:@"2500 Coins"];
        [coins3 setCoinValue:2500];
        [coins3 setCashValue:4.99];
        [coins3 save];
        [self.purchases addObject:coins3];
        
        BVConversionProduct *coins4 = [[BVConversionProduct alloc] initWithIdentifier:@"BombVoyage.7500Coin"];
        [coins4 setName:@"7500 Coins"];
        [coins4 setCoinValue:7500];
        [coins4 setCashValue:8.99];
        [coins4 save];
        [self.purchases addObject:coins4];
        
        BVConversionProduct *coins5 = [[BVConversionProduct alloc] initWithIdentifier:@"BombVoyage.15000Coin"];
        [coins5 setName:@"15000 Coins"];
        [coins5 setCoinValue:15000];
        [coins5 setCashValue:14.99];
        [coins5 save];
        [self.purchases addObject:coins5];
    }
    else{
        //Same but without the setting of values to use less computations to get the data from the core data model
        BVSkinProduct *normalSkin = [BVSkinProduct skinProductWithIdentifier:@"normalSkin"];
        [self.skins addObject:normalSkin];
        
        BVSkinProduct *beastMode = [BVSkinProduct skinProductWithIdentifier:@"beastModeSkin"];
        [self.skins addObject:beastMode];
        
        BVSkinProduct *ninjaSkin = [BVSkinProduct skinProductWithIdentifier:@"ninjaSkin"];
        [self.skins addObject:ninjaSkin];
        
        BVSkinProduct *jackpot = [BVSkinProduct skinProductWithIdentifier:@"jackpot"];
        [self.powerups addObject:jackpot];
        
        BVSkinProduct *fastReflexes = [BVSkinProduct skinProductWithIdentifier:@"fastReflexes"];
        [self.powerups addObject:fastReflexes];
        
        BVSkinProduct *invincibility = [BVSkinProduct skinProductWithIdentifier:@"invincibility"];
        [self.powerups addObject:invincibility];
        
        BVTierProduct *cheatDeath = [BVTierProduct tierProductWithIdentifier:@"cheatDeath"];
        [self.passives addObject:cheatDeath];
        
        BVTierProduct *moneyMaker = [BVTierProduct tierProductWithIdentifier:@"moneyMaker"];
        [self.passives addObject:moneyMaker];
        
        BVTierProduct *powerMaster = [BVTierProduct tierProductWithIdentifier:@"powerMaster"];
        [self.passives addObject:powerMaster];
        
        BVConversionProduct *coins1 = [BVConversionProduct conversionProductWithIdentifier:@"BombVoyage.500Coin"];
        [self.purchases addObject:coins1];
        
        BVConversionProduct *coins2 = [BVConversionProduct conversionProductWithIdentifier:@"BombVoyage.1500Coin"];
        [self.purchases addObject:coins2];
        
        BVConversionProduct *coins3 = [BVConversionProduct conversionProductWithIdentifier:@"BombVoyage.2500Coin"];
        [self.purchases addObject:coins3];
        
        BVConversionProduct *coins4 = [BVConversionProduct conversionProductWithIdentifier:@"BombVoyage.7500Coin"];
        [self.purchases addObject:coins4];
        
        BVConversionProduct *coins5 = [BVConversionProduct conversionProductWithIdentifier:@"BombVoyage.15000Coin"];
        [self.purchases addObject:coins5];
    }
    [self getAllProducts];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Table view data source
//Number of sections
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
//Number of rows in section given by the section and their respective array of data
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
        return self.skins.count;
    else if (section == 1)
        return self.passives.count;
    else if (section == 2)
        return self.powerups.count;
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shared"]){
        return self.purchases.count+1;
    }
    else
        return self.purchases.count;
}
//May not be needed, returns header section title but custom view is put in
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return @"Skins";
    else if (section == 1)
        return @"Upgrades";
    else if (section == 2)
        return @"Powerups";
    else
        return @"Buy More Coins";
}
//Cell method to return cells for each given index path
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        //SKINS section
        SkinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"skinCell"];
        if (cell == nil)
            cell = [[SkinTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"skinCell"];
        //Product is retrieved from array and cell is formatted to the array
        BVSkinProduct *product = [self.skins objectAtIndex:indexPath.row];
        if ([product.identifier isEqualToString:@"normalSkin"])
            cell.thumbnail.image = [UIImage imageNamed:@"center_face"];
        else if ([product.identifier isEqualToString:@"beastModeSkin"])
            cell.thumbnail.image = [UIImage imageNamed:@"beast_center"];
        else
            cell.thumbnail.image = [UIImage imageNamed:@"ninja_center"];
        cell.nameLabel.text = product.name;
        cell.descriptionLabel.text = product.productDescription;
        NSString *selectedSkin = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedSkin"];
        
        //Checks if the values is selected, purchased or not to format the coin view and price title
        if ([selectedSkin isEqualToString:product.identifier]){
            cell.coin.image = [UIImage imageNamed:@"checkmark.png"];
            cell.coin.alpha = 1;
            cell.priceLabel.text = @"Selected";
        }
        else if (product.purchased){
            cell.priceLabel.text = @"Purchased";
            cell.coin.alpha = 0;
        }
        else{
            cell.coin.image = [UIImage imageNamed:@"coin.png"];
            cell.priceLabel.text = [NSString stringWithFormat:@"%i", (int)product.price];
            cell.coin.alpha = 1;
        }
        //Slightly tints every other cell
        if (indexPath.row%2!=0)
            cell.contentView.backgroundColor = [StoreViewController colorWithR:0 G:187 B:246];
        return cell;
    }
    else if (indexPath.section == 1){
        //UPGRADES section
        PassiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"passiveCell"];
        if (cell == nil)
            cell = [[PassiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"passiveCell"];
        //Formats labels and progress bar based on the current tier of the product
        BVTierProduct *product = [self.passives objectAtIndex:indexPath.row];
        cell.thumbnail.image = [UIImage imageNamed:product.identifier];
        cell.nameLabel.text = product.name;
        cell.descripionLabel.text = [product currentDescription];
        cell.tierSlider.progress = 0.25*product.tierNumber;
        //Formats price label wheather it has been purchased or not
        if (product.purchased)
        {
            cell.coin.alpha = 0;
            cell.priceLabel.text = @"Purchased";
        }
        else{
            cell.priceLabel.text = [NSString stringWithFormat:@"%i", (int)product.currentPrice];
            cell.coin.alpha = 1;
        }
        //Slightly Tints every other cell
        if (indexPath.row%2!=0)
            cell.contentView.backgroundColor = [StoreViewController colorWithR:0 G:187 B:246];
        return cell;
    }
    else if (indexPath.section == 2){
        SkinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"skinCell"];
        if (cell == nil)
            cell = [[SkinTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"skinCell"];
        //Format views and labels like other sections
        BVSkinProduct *product = [self.powerups objectAtIndex:indexPath.row];
        cell.thumbnail.image = [UIImage imageNamed:product.identifier];
        cell.nameLabel.text = product.name;
        cell.descriptionLabel.text = product.productDescription;
        //Formats price label and coin view
        if (product.purchased)
        {
            cell.coin.alpha = 0;
            cell.priceLabel.text = @"Purchased";
        }
        else{
            cell.priceLabel.text = [NSString stringWithFormat:@"%i", (int)product.price];
            cell.coin.image = [UIImage imageNamed:@"coin.png"];
            cell.coin.alpha = 1;
        }
        //Tints every other cell
        if (indexPath.row%2!=0)
            cell.contentView.backgroundColor = [StoreViewController colorWithR:0 G:187 B:246];
        return cell;
    }
    else{
        //PURCHASE section
        SkinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"purchaseCell"];
        if(cell == nil)
            cell = [[SkinTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"purchaseCell"];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shared"]){
            if (indexPath.row == 0){
                cell.nameLabel.text = @"Share for 500 Coins";
                cell.descriptionLabel.text = @"Requires Facebook or Twitter app";
                cell.coin.alpha = 1;
                cell.priceLabel.text = @"Free";
                cell.thumbnail.image = [UIImage imageNamed:@"BombVoyage.500Coin"];
            }
            else{
                BVConversionProduct *product = [self.purchases objectAtIndex:indexPath.row-1];
                cell.nameLabel.text = product.name;
                cell.thumbnail.image = [UIImage imageNamed:product.identifier];
                //Description label formatted with coin conversion
                cell.descriptionLabel.text = [NSString stringWithFormat:@"Add %i coins to your stash", (int)product.coinValue];
                cell.coin.alpha = 1;
                cell.priceLabel.text = [NSString stringWithFormat:@"US $%.2f", product.cashValue];
            }
        }
        else{
            BVConversionProduct *product = [self.purchases objectAtIndex:indexPath.row];
            cell.nameLabel.text = product.name;
            cell.thumbnail.image = [UIImage imageNamed:product.identifier];
            //Description label formatted with coin conversion
            cell.descriptionLabel.text = [NSString stringWithFormat:@"Add %i coins to your stash", (int)product.coinValue];
            cell.coin.alpha = 1;
            cell.priceLabel.text = [NSString stringWithFormat:@"US $%.2f", product.cashValue];
        }
        //Formats string to give a US$ format for the coin to cash conversions

        //Tints every other cell
        if (indexPath.row%2!=0)
            cell.contentView.backgroundColor = [StoreViewController colorWithR:0 G:187 B:246];
        return cell;
    }
}
//Custom view put in to change font, color, and background color of each header section
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Heiti SC Medium" size:12.0]];
    [label setText:self.headerNames[section]];
    [label setTextColor:[UIColor blueColor]];
    [view addSubview:label];
    return view;
}
//Remove selection from all cells to avoid UI effects
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
//Called if a certain cell is selected, controls selection of skin, retrieving in app purchases, and purchasing of all products from the store
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        //Skin was selected
        BVSkinProduct *product = [self.skins objectAtIndex:indexPath.row];
        if (product.purchased)
        {
            //Selected already purchased skin
            //Iterates through all skins to format selected value with a checkmark and reset all other values. Will either set values to selected, purchased, or not purchased
            for (int k = 0;k<[tableView numberOfRowsInSection:indexPath.section];k++){
                SkinTableViewCell *cell = (SkinTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:indexPath.section]];
                if (k == indexPath.row){
                    cell.coin.alpha = 1;
                    cell.coin.image = [UIImage imageNamed:@"checkmark.png"];
                    cell.priceLabel.text = @"Selected";
                }
                else{
                    cell.coin.image = [UIImage imageNamed:@"coin.png"];
                    BVSkinProduct *temp = [self.skins objectAtIndex:k];
                    if (temp.purchased){
                        cell.priceLabel.text = @"Purchased";
                        cell.coin.alpha = 0;
                    }
                    else{
                        cell.priceLabel.text = [NSString stringWithFormat:@"%i", (int)temp.price];
                        cell.coin.alpha = 1;
                    }
                }
            }
            //Stores selected skin
            [[NSUserDefaults standardUserDefaults] setObject:product.identifier forKey:@"selectedSkin"];
        }
        else{
            //If it has not been purchased checks to see if purchasable, if so it purchases and selects the same way.
            if (self.coinPurse>=product.price){
                self.coinPurse-=product.price;
                [[NSUserDefaults standardUserDefaults] setInteger:self.coinPurse forKey:@"coinPurse"];
                self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
                //Saves purchase
                [product purchase];
                [product save];
                //Saves selection and iterates to format all cells
                [[NSUserDefaults standardUserDefaults] setObject:product.identifier forKey:@"selectedSkin"];
                for (int k = 0;k<[tableView numberOfRowsInSection:indexPath.section];k++){
                    SkinTableViewCell *cell = (SkinTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:indexPath.section]];
                    if (k == indexPath.row){
                        cell.coin.alpha = 1;
                        cell.coin.image = [UIImage imageNamed:@"checkmark.png"];
                    }
                    else
                    {
                        cell.coin.image = [UIImage imageNamed:@"coin.png"];
                        BVSkinProduct *temp = [self.skins objectAtIndex:k];
                        if (temp.purchased){
                            cell.priceLabel.text = @"Purchased";
                            cell.coin.alpha = 0;
                        }
                        else
                            cell.priceLabel.text = [NSString stringWithFormat:@"%i", (int)temp.price];
                    }
                }
            }
            else{
                //Purchase requires more coins, uialertview is shown
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Coins!" message:[NSString stringWithFormat:@"Need %i more coins for purchase", (int)(product.price-self.coinPurse)] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else if (indexPath.section == 1){
        //Passive upgrade is selected for purchase. Checks if purchasable. If so saves purchase and decreases coin amount else shows uialertview with amount of coins needed
        BVTierProduct *product = [self.passives objectAtIndex:indexPath.row];
        if (!product.purchased){
            if (self.coinPurse>=product.currentPrice){
                self.coinPurse-=product.currentPrice;
                [[NSUserDefaults standardUserDefaults] setInteger:self.coinPurse forKey:@"coinPurse"];
                [product purchase];
                [product save];
                self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Coins!" message:[NSString stringWithFormat:@"Need %i more coins for purchase", (int)(product.currentPrice-self.coinPurse)] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else if (indexPath.section == 2){
        //Powerup is selected for purchase. Checks if purchasable. If so saves purchase and decreases coin amount else shows uialertview with amount of coins needed
        BVSkinProduct *product = [self.powerups objectAtIndex:indexPath.row];
        if (!product.purchased){
            if (self.coinPurse>=product.price){
                self.coinPurse-=product.price;
                [[NSUserDefaults standardUserDefaults] setInteger:self.coinPurse forKey:@"coinPurse"];
                [product purchase];
                [product save];
                self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Coins!" message:[NSString stringWithFormat:@"Need %i more coins for purchase", (int)(product.price-self.coinPurse)] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else{
        //Calls method to retrieve in app purchase info for given product
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shared"]){
            if (indexPath.row == 0)
                [self share];
            else if (!purchasing&&self.skproducts){
                NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self beginTransactionWithIndexPath:index];
            }
        }
        else{
            if (!purchasing&&self.skproducts)
                [self beginTransactionWithIndexPath:indexPath];
        }
        
    }
    //Reloads all table data
    [tableView reloadData];
}

#pragma mark - Helper and View Controller Methods
- (IBAction)dismissButton:(id)sender {
    //Dismisses this view controller when back button is pressed
    [self dismissViewControllerAnimated:YES completion:nil];
}
//Method called that pulls up an activity window with possible sharing options for exchange of 500 coins upon completion. Share will fail if text box is empty or user presses cancel. Defaults to sharing your high score.

- (void)share{
    //Gets high score from user defaults and sets default shared text.
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    NSString *text = [NSString stringWithFormat:@"I Scored %i coins on Bomb Voyage. Try and beat my score here!", (int)highScore.integerValue];
    //Link of app store profile also shared with activiy controller that cant be deleted.
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id955896287"];
    UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[text, url] applicationActivities:nil];
    
    //Set completion block to award coins upon sharing. The share feature can only be done once and is removed from the store
    [viewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        if (activityError)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Failed" message:[NSString stringWithFormat:@"%@", activityError.localizedFailureReason] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else if (completed&&activityType)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank You for Sharing!" message:@"500 Coins have been rewarded to you" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
            self.coinPurse+=500;
            [[NSUserDefaults standardUserDefaults] setInteger:self.coinPurse forKey:@"coinPurse"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shared"];
            self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
            [self.tableView reloadData];
        }
        else
            NSLog(@"Cancelled Share");
    }];
    //Exclude options that arent feasible
    [viewController setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePostToTencentWeibo, UIActivityTypePostToFlickr, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    //Present in view controller.
    [self presentViewController:viewController animated:YES completion:nil];
}
+(UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue{
    //helper method that converts rgb float values to UIColor object
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

#pragma mark - StoreKit Methods
//Method for starting transaction with given product
-(void)beginTransactionWithIndexPath:(NSIndexPath*)path{
    purchasing = YES;
    
    NSString *identifier = [(BVConversionProduct*)[self.purchases objectAtIndex:path.row] identifier];
    SKProduct *selectedProduct = [self.skproducts objectAtIndex:0];
    for (SKProduct *product in self.skproducts){
        if ([product.productIdentifier isEqualToString:identifier]){
            selectedProduct = product;
            break;
        }
    }
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if ([response products].count==0){
        NSLog(@"No Products Found");
    }
    else{
        //If products were found starts a payment and adds it to the payment queue
        self.skproducts = [[NSMutableArray alloc] initWithArray:response.products];
    }
}
//Method that manageds current transactions
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //Iterates through all transactions
    for (SKPaymentTransaction *transaction in transactions){
        SKPaymentTransactionState state = transaction.transactionState;
        //If one has been purchased, ends transaction and increases coin amount by the given transaction conversion rate
        if (state == SKPaymentTransactionStatePurchased){
            if ([transaction.payment.productIdentifier isEqualToString:@"BombVoyage.500Coin"]){
                self.coinPurse+=500;
            }
            else if ([transaction.payment.productIdentifier isEqualToString:@"BombVoyage.1250Coin"]){
                self.coinPurse+=1500;
            }
            else if ([transaction.payment.productIdentifier isEqualToString:@"BombVoyage.2500Coin"]){
                self.coinPurse+=2500;
            }
            else if ([transaction.payment.productIdentifier isEqualToString:@"BombVoyage.7500Coin"]){
                self.coinPurse+=7500;
            }
            else if ([transaction.payment.productIdentifier isEqualToString:@"BombVoyage.15000Coin"]){
                self.coinPurse+=15000;
            }
            //Saves coins to user defaults
            self.coinItem.title = [NSString stringWithFormat:@"%i Coins", (int)self.coinPurse];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:self.coinPurse forKey:@"coinPurse"];
            [defaults synchronize];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            purchasing = NO;
        }
        else if (state == SKPaymentTransactionStateFailed){
            //Transaction was either cancelled or failed, prints different uialertview depending on situation
            if (transaction.error.code == SKErrorPaymentCancelled){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transaction Cancelled" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:transaction.error.localizedFailureReason delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                [alertView show];
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            purchasing = NO;
        }
    }
}
//Gets product identifiers and send a product request with all the identifiers.
-(void)getAllProducts{
    if ([SKPaymentQueue canMakePayments]){
        NSMutableArray *array = [NSMutableArray array];
        for (BVConversionProduct *product in self.purchases){
            [array addObject:product.identifier];
        }
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:array]];
        request.delegate = self;
        [request start];
    }
}
@end
