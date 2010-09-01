# Messages plugin for Movable Type

This plugin provides an easy method for other plugins to add a status message to any page in the MT CMS UI, simply by adding to the `messages` registry key.

    messages:
      edit_entry:
        my_msg:
          label: 'This is my message'
          class: 'info'
          condition: sub { my ($app) = @_; return 1; }
	  
The condition method defaults to simply checking for the key in the applications parameters (e.g., `sub { return $_[0]->param('my_msg') }` in this case).  The method is passed the application object.

Instead of the `label` key, you can instead pass a `handler` key, which will also be passed the application object.  If both `handler` and `label` are present, the `handler` will be used.
