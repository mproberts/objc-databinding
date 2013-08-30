objc-databinding
================

Simple KVO data binding category for `NSObject`

## Examples

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
