Meteor.publishCounter = (params) ->
  count = 0
  init = true
  id = Random.id()
  pub = params.handle
  collection = params.collection
  handle = collection.find(params.filter, params.options).observeChanges
    added: =>
      count++
      pub.changed(params.name, id, {count: count}) unless init
    removed: =>
      count--
      pub.changed(params.name, id, {count: count}) unless init
  init = false
  pub.added params.name, id, {count: count}
  pub.ready()
  pub.onStop -> handle.stop()