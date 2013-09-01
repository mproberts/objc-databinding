objc-databinding
================

Simple KVO data binding category for `NSObject`

## Examples

### UIView Binding

```objective-c
UIView *userProfileView = [[UIView alloc] init];

UILabel *displayNameLabel = [[UILabel alloc] init];
UILabel *usernameLabel = [[UILabel alloc] init];
UIImageView *profilePic = [[UIImageView alloc] init];

[userProfileView addSubview:profilePic];
[userProfileView addSubview:displayNameLabel];
[userProfileView addSubview:usernameLabel];

// Setup layout
// ...

displayNameLabel.textKeyPath = @"fullName";
usernameLabel.textKeyPath = @"username";

// bindings can be applied even when the data types don't necessarily match
profilePic.imageKeyPath = @"profilePicUrl";

// just apply a binding transform and callback with the converted data
// you can even do this asynchronously, or multiple times per change
profilePic.imageTransform = ^(NSURL *url, transform_completed_t callback) {
    UIImage *profilePic = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    // don't worry about being on the UI thread when you callback
    // you'll be put there automatically
    callback(profilePic);
};

// default values can be supplied for any binding
displayNameLabel.textDefault = @"John Doe";
usernameLabel.textDefault = @"unknown";
profilePic.imageDefault = [UIImage imageNamed:@"default-profilepic.png"];

// Just bind the data to any superview of the bound views and you're all set!
// -------
userProfileView.dataSource = superAwesomeUser;

```

### Simple Text Binding

```objective-c
[cell.textLabel bindKeyPath:@"text"
                  toKeyPath:@"title"
                   onObject:item
               defaultValue:@"Default Title"];
```

### Image Binding with a Transform

```objective-c
[cell.imageView bindKeyPath:@"image"
                  toKeyPath:@"color"
                   onObject:item
              transformedBy:^(NSString *color) {
                  UIImage *loadedImage = nil;
                  
                  if (color) {
                      loadedImage = [UIImage imageNamed:[NSString stringWithFormat:@"img-%@.png", color]];
                  }
                  
                  return loadedImage;
              }];
```
