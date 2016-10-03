Batch Endpoint
==============

This rails gem provides a simple batch endpoint to an existing rails application. Requests are relayed via HTTP.

Your environment will need to be able to handle at least two concurrent requests for this to work as the initial request will generate subsequent requests to the same URL.

### Usage

In your Gemfile:

```
gem 'batchy', git: 'https://github.com/rdmcfee/batchy.git
```

In config/routes.rb

```
batchify 'some/path'
```

This will mount the `BatchController` on an endpoint at `some/path/batch.json`
