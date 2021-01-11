#import "SettingsTableViewController.h"

#import "AppDelegate.h"
#import "Config.h"
#import "PListCommunication.h"

@interface SettingsTableViewController () {
  Config *_config;
  PListCommunication *_communication;
}
@end

typedef enum : NSUInteger {
  BoatSection,
  InfoSection,
  EndSection,
} SettingSection;

typedef enum : NSUInteger {
  ChooserBoatCellIndex,
  LightBoatCellIndex,
  CameraBoatCellIndex,
  RecordTripBoatCellIndex,
  MotorCoefBoatCellIndex,
  BootBoatCellIndex,
  CommandBoatCellIndex,
  EndBoatCellIndex,
} BoatCellIndex;

typedef enum : NSUInteger {
  CompileInfoCelIndex,
  EndInfoCellIndex,
} InfoCellIndex;

@implementation SettingsTableViewController

+ (UIColor*)backgroundColor {
  return [UIColor colorWithRed:239./255. green:239./255. blue:244./255. alpha:1.0];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  _config = appDelegate.config;
  _communication = appDelegate.communication;
  self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedSectionHeaderHeight = 36;
  self.tableView.backgroundColor = [[self class] backgroundColor];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  self.tableView.tableFooterView.backgroundColor = [[self class] backgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

- (NSString *)cellIdentifierWithIndexPath:(NSIndexPath *)indexPath {
  switch ((SettingSection)indexPath.section) {
    case BoatSection:
      switch ((BoatCellIndex)indexPath.row) {
        case ChooserBoatCellIndex:
        case CameraBoatCellIndex:
          return @"DisclosureIndicatorCell";
        case LightBoatCellIndex:
        case RecordTripBoatCellIndex:
          return @"DefaultCell";
        case BootBoatCellIndex:
          return @"RightDetailCell";
        case MotorCoefBoatCellIndex:
          return @"MotorCoefCell";
        case CommandBoatCellIndex:
          return @"DisclosureIndicatorCell";
        case EndBoatCellIndex:
          break;
      }
      break;
    case InfoSection:
      return @"RightDetailCell";
    case EndSection:
      break;
  }
  NSAssert(NO, @"Unknow section %ld", indexPath.section);
  return nil;
}

- (UISwitch *)switchWithAction:(SEL)action value:(BOOL)value {
  UISwitch *uiswitch = [[UISwitch alloc] initWithFrame:CGRectZero];
  [uiswitch addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
  uiswitch.on = value;
  return uiswitch;
}

- (UITableViewCell *)boatCellWithIndexPath:(NSIndexPath *)indexPath {
  NSAssert(indexPath.section == BoatSection, @"Wrong section %ld", indexPath.section);
  NSString *cellIdentifier = [self cellIdentifierWithIndexPath:indexPath];
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  switch ((BoatCellIndex)indexPath.row) {
    case ChooserBoatCellIndex:
      cell.textLabel.text = _config.boatName;
      break;
    case LightBoatCellIndex:
      cell.accessoryView = [self switchWithAction:@selector(lightAction:) value:[_communication.allValues[@"led"][@"right%"] boolValue]];
      cell.textLabel.text = @"Light";
      break;
    case CameraBoatCellIndex:
      cell.textLabel.text = @"Camera";
      break;
    case RecordTripBoatCellIndex:
      cell.accessoryView = [self switchWithAction:@selector(recordTripAction:) value:[_communication.allValues[@"record"] boolValue]];
      cell.textLabel.text = @"Record Trip";
      break;
    case BootBoatCellIndex:
      cell.textLabel.text = @"Boot Time";
      cell.detailTextLabel.text = [AppDelegate stringWithTimestamp:[_communication.allValues[@"bttmstmp"] doubleValue]];
      break;
    case MotorCoefBoatCellIndex:
      cell.textLabel.text = [NSString stringWithFormat:@"Motor Coef %d%%", (int)(_communication.motorCoef * 100)];
      [(UISlider *)cell.accessoryView addTarget:self action:@selector(motorCoefAction:) forControlEvents:UIControlEventTouchUpInside];
      [(UISlider *)cell.accessoryView setValue:_communication.motorCoef];
      break;
    case CommandBoatCellIndex:
      cell.textLabel.text = @"Commands";
      break;
    case EndBoatCellIndex:
      break;
  }
  return cell;
}

- (UITableViewCell *)infoCellWithIndexPath:(NSIndexPath *)indexPath {
  NSAssert(indexPath.section == InfoSection, @"Wrong section %ld", indexPath.section);
  NSString *cellIdentifier = [self cellIdentifierWithIndexPath:indexPath];
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  }
  switch ((InfoCellIndex)indexPath.row) {
    case CompileInfoCelIndex:
      cell.textLabel.text = @"Compiled";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%s %s", __DATE__, __TIME__];
      break;
    case EndInfoCellIndex:
      NSAssert(NO, @"%ld", indexPath.row);
      break;
  }
  return cell;
}

#pragma mark - Action

- (void)lightAction:(UISwitch *)sender {
  if (sender.on) {
    [_communication setValues: @{ @"light": @(2) }];
  } else {
    [_communication setValues: @{ @"stop light": @(0) }];
  }
}

- (void)cameraAction:(UISwitch *)sender {
  [_communication setValues: @{ @"camera": @{ @"state": @(sender.on), @"live_stream_name": @"" } }];
}

- (void)recordTripAction:(UISwitch *)sender {
  [_communication setValues: @{ @"record": @(sender.on) }];
}

- (void)motorCoefAction:(UISlider *)sender {
  float value = sender.value;
  value = roundf(value * 10) / 10;
  sender.value = value;
  AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  appDelegate.motorCoef = value;
  NSIndexPath *indexpath = [NSIndexPath indexPathForRow:MotorCoefBoatCellIndex inSection:BoatSection];
  [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:NO];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  switch ((SettingSection)indexPath.section) {
    case BoatSection:
      switch ((BoatCellIndex)indexPath.row) {
        case ChooserBoatCellIndex:
        case CameraBoatCellIndex:
        case CommandBoatCellIndex:
          return YES;
        case LightBoatCellIndex:
        case RecordTripBoatCellIndex:
        case BootBoatCellIndex:
        case MotorCoefBoatCellIndex:
          return NO;
        case EndBoatCellIndex:
          break;
      }
      break;
    case InfoSection:
      return NO;
    case EndSection:
      break;
  }
  NSAssert(NO, @"Unknown section %ld row %ld", indexPath.section, indexPath.row);
  return NO;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  view.backgroundColor = [[self class] backgroundColor];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 100, 100)];
  [view addSubview:label];
  switch ((SettingSection)section) {
    case BoatSection:
      label.text = @"Boat";
      break;
    case InfoSection:
      label.text = @"Info";
      break;
    case EndSection:
      NSAssert(NO, @"Unknown section %ld", section);
      break;
  }
  label.translatesAutoresizingMaskIntoConstraints = NO;
  [view addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|-(8)-[label]-(>=8)-|"
                        options:NSLayoutFormatAlignAllCenterY
                        metrics:0
                        views:@{@"label":label}]];
  [view addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|-(12)-[label]-(8)-|"
                        options:NSLayoutFormatAlignAllCenterY
                        metrics:0
                        views:@{@"label":label}]];
  return view;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return EndSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case BoatSection:
      return EndBoatCellIndex;
    case InfoSection:
      return EndInfoCellIndex;
    case EndSection:
      break;
  }
  NSAssert(NO, @"Unknow section %ld", section);
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case BoatSection:
      return [self boatCellWithIndexPath:indexPath];
    case InfoSection:
      return [self infoCellWithIndexPath:indexPath];
    default:
      break;
  }
  NSAssert(NO, @"Unknow section %ld", indexPath.section);
  return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch ((BoatCellIndex)indexPath.row) {
    case ChooserBoatCellIndex:
      [self performSegueWithIdentifier:@"BoatChooser" sender:self];
      break;
    case CommandBoatCellIndex:
      [self performSegueWithIdentifier:@"Command" sender:self];
      break;
    case CameraBoatCellIndex:
      [self performSegueWithIdentifier:@"CameraSettings" sender:self];
      break;
    case LightBoatCellIndex:
    case RecordTripBoatCellIndex:
    case BootBoatCellIndex:
    case MotorCoefBoatCellIndex:
    case EndBoatCellIndex:
      break;
  }
}

@end
