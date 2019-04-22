//
//  OEXMySettingsViewController.m
//  edXVideoLocker
//
//  Created by Abhradeep on 20/02/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXMySettingsViewController.h"

#import "edX-Swift.h"

#import "NSString+OEXFormatting.h"
#import "OEXInterface.h"
#import "OEXStyles.h"

typedef NS_ENUM(NSUInteger, OEXMySettingsAlertTag) {
    OEXMySettingsAlertTagNone,
    OEXMySettingsAlertTagWifiOnly
};

@interface OEXMySettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell* wifiOnlyCell;
@property (weak, nonatomic) IBOutlet UISwitch* wifiOnlySwitch;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation OEXMySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.wifiOnlySwitch setOn:[OEXInterface shouldDownloadOnlyOnWifi]];
    [self.wifiOnlySwitch setOnTintColor:[OEXStyles sharedStyles].primaryBaseColor];
    
    [self.subtitleLabel setTextAlignment:NSTextAlignmentNatural];
    [self.subtitleLabel setText:[Strings wifiOnlyDetailMessage]];
    
    OEXTextStyle *textStyle = [[OEXTextStyle alloc] initWithWeight:OEXTextWeightNormal size:OEXTextSizeLarge color:[[OEXStyles sharedStyles] neutralBlack]];
    self.titleLabel.attributedText = [textStyle attributedStringWithText:[Strings wifiOnlyTitle]];

    self.wifiOnlyCell.accessibilityLabel = [NSString stringWithFormat:@"%@ , %@", self.titleLabel.text, self.subtitleLabel.text];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.title = [Strings settings];
    [self initTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[OEXAnalytics sharedAnalytics] trackScreenWithName:OEXAnalyticsScreenSettings];
    self.tableView.tableFooterView = [UIView new];
}

- (void)initTableView {
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#e6e9ed"];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        return self.wifiOnlyCell.bounds.size.height;
    }
    return 46;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        return self.wifiOnlyCell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logoutCell"];
            OEXTextStyle *textStyle = [[OEXTextStyle alloc] initWithWeight:OEXTextWeightNormal size:OEXTextSizeLarge color:[[OEXStyles sharedStyles] neutralBlack]];
        cell.textLabel.attributedText = [textStyle attributedStringWithText:Strings.logout];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (self.logoutHandle) {
            self.logoutHandle();
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (IBAction)wifiOnlySwitchValueChanged:(id)sender {
    if(!self.wifiOnlySwitch.isOn) {
        
        [[UIAlertController alloc] showInViewController:self title:[Strings cellularDownloadEnabledTitle] message:[Strings cellularDownloadEnabledMessage] preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:[Strings allow] destructiveButtonTitle:nil otherButtonsTitle:@[[Strings doNotAllow]] tapBlock:^(UIAlertController *alertController, UIAlertAction *alertAction, NSInteger buttonIndex) {
            // Allow
            if ( buttonIndex == 0 ) {
                [OEXInterface setDownloadOnlyOnWifiPref:self.wifiOnlySwitch.isOn];
            }
            // Don't Allow
            else if ( buttonIndex == 1 ) {
                [self.wifiOnlySwitch setOn:YES animated:YES];
            }
        } textFieldWithConfigurationHandler:nil];
    }
    else {
        [OEXInterface setDownloadOnlyOnWifiPref:self.wifiOnlySwitch.isOn];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

@end
