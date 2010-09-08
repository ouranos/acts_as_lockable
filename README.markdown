ActsAsLockable
==============

ActiveRecord plugin allowing row/table level locking throughout multiple requests.


Example
-------

In your model:

    class Article
      acts_as_lockable
    end

Then :
    @article.lock("John Doe", "Very important update")
    @article.unlock
    @article.locked?

TODO
----

* Optimise queries
* Update documentation

Copyright (c) 2010 Olivier Brisse, released under the MIT license
