---秒杀券id    ARGV是调用方法时传递的参数
local voucherId = ARGV[1]
--用户id
local userId = ARGV[2]
--订单id
local id = ARGV[3]
--库存key .. 符号是 Lua 语言中的字符串连接运算符  voucherId 的值为 123，则最终的 stockKey 的值为 'seckill:stock:123'
local stockKey = 'seckill:stock:' .. voucherId
--订单key
local orderKey = 'seckill:order:' .. voucherId

--库存是否充足
--库存不足  如果商品库存量已经为 0 或者小于 0，则无法进行购买，返回数字 1 表示秒杀失败
if (tonumber(redis.call('get', stockKey)) <= 0) then
    return 1
end

--判断用户是否下单
--存在用户 禁止重复下单
--redis.call('sismember', orderKey, userId) 用于检查 Redis 中对应的 set集合orderKey 是否包含指定的元素userId
--redis.call('sismember', orderKey, userId) 用于检查 Redis 中对应的 set 集合 orderKey 是否包含指定的元素 userId
if (tonumber(redis.call('sismember', orderKey, userId)) == 1) then
    return 2
end

--扣减库存
redis.call('incrby',stockKey,-1)
--下单（保存用户）
redis.call('sadd',orderKey,userId)
--发送消息
redis.call('xadd','stream.orders','*','userId',userId,'voucherId',voucherId,'id',id)
return 0

