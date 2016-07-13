# consul-search
quick and dirty UI to search for keys and values in consul. 

[Consul](https://www.consul.io/) is a service discovery and configuration management platform. It can be said to be in the same league as `etcd`, `zookeeper`, `eureka` etc. Add to that - it works across datacenters. Add to that - it is very simple. Recently, we have been using `consul` for keeping configuration management by using it as a `key value store`. You can read more about `consul`, `consul-template` and `consul-webui` by using any of your [favorite](https://duckduckgo.com/) [search] (https://www.google.com) [engines] (https://www.bing.com). 

If you have a team size of more than a few then it becomes difficult to track that people do not create duplicate keys (`different name but same values`) and it then requires that people should be able to *easily* check if there is already a value added and what its corresponding key is. This [feature request](https://github.com/hashicorp/consul/issues/1905) is already open on consul and doesn't look like a priority as of now: 

https://github.com/hashicorp/consul/issues/1905

So here comes the purpose of this project - to act as a temporary filler for the above request. 

# Getting Started 

```
$ git clone https://github.com/awmanoj/consul-search.git
$ cd consul-search
$ export CONSUL_HOST=`YOUR_CONSUL_HOST`
$ export CONSUL_PORT=`YOUR_CONSUL_PORT`
$ bash bootstrap.sh   
```

# Idea

Basically I want to use `consul-template` [0][1], `elastic search` [2], `elasticui` [3] to create a quick UI for the search. `consul-template` is used to query all key-values and dump them to a file in a format in which they can be `indexed` in a `local instance` (not mandatory) of `elastic search`. `elasticui` is an awesome piece of UI written by [Yousef] (https://github.com/YousefED) and is used as a elastic search plugin to provide the UI for search. I have simply used a very slight modification of the `demo` example provided by Yousef for the page. 

* [0] https://www.hashicorp.com/blog/introducing-consul-template.html
* [1] https://github.com/hashicorp/consul-template 
* [2] https://www.elastic.co/products/elasticsearch
* [3] http://www.elasticui.com/

# Limitations 

Depending on the size of data on your `consul` cluster you may need appropriate `elastic search` setup. In my case it is limited to `few thousand keys` and a single node setup with limited memory works. As I already mentioned it's a quick and dirty setup but I think you get the idea and can modify accordingly for scaling. 

# Notes (todo)

* externalize key prefix in `.ctmpl` code. `.ctmpl` looks for keys with prefix `service`.
* externalize `index name`, `type` (unused currently). 

