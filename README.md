# Hammer #

A Key/Value store library.

## API ##

* K/V store: Get/Set/Remove values.
* Lists manipulation: Push/Pop/List values.  

### Example ###

K/V:

    [HMRStore sharedInstance] value:@"bastos" forKey:@"user" error:NULL];
    [HMRStore sharedInstance] valueforKey:@"user" error:NULL];
    [HMRStore sharedInstance] removeValueForKey:@"user" error:NULL];

Lists:

    [HMRStore sharedInstance] pushValue:@"1" toList:@"test" error:NULL];
    [HMRStore sharedInstance] pushValue:@"2" toList:@"test" error:NULL];    
    [HMRStore sharedInstance] popValueFromList:@"test" error:NULL];
    [HMRStore sharedInstance] valuesFromList:@"test" error:NULL];

## License ##

MIT License (read LICENSE)

## Authors ##

* Tiago Bastos <bastos@guildahq.com>