QUnit.module "Utils"

testWithSession "when the path parts are greater than avail", (assert) ->
  sinon.stub(@Breezy.Utils, 'warn', ->{})
  page = {}
  clone = (new @Breezy.Grafter).graftByKeypath('a.b.c', 0 ,page)
  assert.strictEqual page, clone

testWithSession "when its not a tree like structure", (assert) ->
  page = null
  clone = (new @Breezy.Grafter).graftByKeypath('a.b.c', 0 , page)
  assert.strictEqual page, clone

testWithSession "when the path does not exist", (assert) ->
  sinon.stub(@Breezy.Utils, 'warn', ->{})
  page = a: b: c: d: 5
  clone = (new @Breezy.Grafter).graftByKeypath('a.b.z', foo: 'bar', page)

  assert.strictEqual page, clone
  assert.propEqual page, clone

# not broken, but disabled for now...
# testWithSession "receiving a warning when the obj path does not exist", (assert) ->
#   warn = sinon.stub(@Breezy.Utils, 'warn');
#   page = a: b: c: d: b
#   clone = (new @Breezy.Grafter).graftByKeypath('a.b.z', foo: 'bar', page)
#
#   assert.ok warn.calledWith('Could not find key z in keypath a.b.z')
#
# testWithSession "receiving a warning when the array path does not exist", (assert) ->
#   page = a: b: [
#     {id: 1},
#     {id: 2},
#     {id: 3}
#   ]
#   warn = sinon.stub(@Breezy.Utils, 'warn');
#   clone = (new @Breezy.Grafter).graftByKeypath('a.b.id=4', foo: 'bar', page)
#
#   assert.ok warn.calledWith('Could not find key id=4 in keypath a.b.id=4')

testWithSession "replaces the node at keypath", (assert) ->
  page = a: b: c: d: 5
  clone = (new @Breezy.Grafter).graftByKeypath('a.b.c', foo: 'bar', page)
  assert.notStrictEqual page, clone
  assert.propEqual clone, a: b: c: foo: 'bar'

testWithSession "replaces the entire branch with new objects, but leave siblins alone", (assert) ->
  graft1 = c: d: e: 5
  graft2 = i: j: k: 10

  page = a:
    b: graft1
    h: graft2

  clone = (new @Breezy.Grafter).graftByKeypath('a.b.c.d', foo: 'bar', page)
  assert.notStrictEqual clone.a.b, graft1
  assert.strictEqual clone.a.h, graft2

  assert.propEqual clone,
    a:
      b: c: d: foo: 'bar'
      h: i: j: k: 10

testWithSession "objects in arrays can be referenced using an id attribute", (assert) ->
  page = a: b: [
    {id: 1},
    {id: 2},
    {id: 3}
  ]

  clone = (new @Breezy.Grafter).graftByKeypath('a.b.id=2', {id:2, foo: 'bar'}, page)
  assert.notStrictEqual page, clone
  assert.strictEqual page.a.b[0], clone.a.b[0]
  assert.strictEqual page.a.b[2], clone.a.b[2]
  assert.propEqual clone,  a: b: [
    {id: 1},
    {id: 2, foo: 'bar'},
    {id: 3}
  ]

testWithSession "objects can be added using to an array an id attribute", (assert) ->
  page = a: b: [
    {id: 1},
    {id: 2},
    {id: 3}
  ]

  clone = (new @Breezy.Grafter).graftByKeypath('a.b', {id:4}, page, type: 'add')
  assert.notStrictEqual page, clone
  assert.notStrictEqual page.a.b, clone.a.b
  assert.strictEqual page.a.b[0], clone.a.b[0]
  assert.strictEqual page.a.b[2], clone.a.b[2]
  assert.propEqual clone,  a: b: [
    {id: 1},
    {id: 2},
    {id: 3},
    {id: 4}
  ]

testWithSession "objects in arrays can be referenced using an index", (assert) ->
  page = a: b: [
    {id: 1},
    {id: 2},
    {id: 3}
  ]

  clone = (new @Breezy.Grafter).graftByKeypath('a.b.1', {id:2, foo: 'bar'}, page)
  assert.notStrictEqual page, clone
  assert.strictEqual page.a.b[0], clone.a.b[0]
  assert.strictEqual page.a.b[2], clone.a.b[2]
  assert.propEqual clone,  a: b: [
    {id: 1},
    {id: 2, foo: 'bar'},
    {id: 3}
  ]
