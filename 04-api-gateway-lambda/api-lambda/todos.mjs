import { DynamoDBClient, BatchWriteItemCommand, QueryCommand, PutItemCommand, GetItemCommand } from "@aws-sdk/client-dynamodb";

const PER_PAGE = 2;
const client = new DynamoDBClient();

const serializeTodo = (item) => ({
  id: { N: item.id.toString() },
  userId: { N: item.userId.toString() },
  createdAt: { N: item.createdAt.toString() },
  todo: { S: item.todo },
  done: { BOOL: item.done },
});

const parseTodo = (attribute) => ({
  id: parseInt(attribute.id.N),
  userId: parseInt(attribute.userId.N),
  createdAt: parseInt(attribute.createdAt.N),
  todo: attribute.todo.S,
  done: attribute.done.BOOL,
});

export async function seedTodos() {
  // 100 users
  for (let i = 0; i < 100; i++) {
    const userId = i + 1;
    const todoItems = [];
    for (let j = 0; j < 10; j++) {
      const postId = (i * 10) + j + 1;
      todoItems.push({
        id: postId,
        userId,
        createdAt: Date.now() + j,
        todo: `User ${userId}, item ${j + 1}`,
        done: false,
      });
    }
    const dynamoItems = todoItems.map((item) => ({
      PutRequest: { Item: serializeTodo(item) },
    }));
    const command = new BatchWriteItemCommand({
      RequestItems: {
        todos2: dynamoItems,
      },
    });
    await client.send(command);
  }
}

export async function getTodos({ userId, exclusiveStartKey }) {
  const command = new QueryCommand({
    TableName: 'todos2',
    IndexName: 'userId-createdAt-index',
    KeyConditionExpression: 'userId = :userId',
    ExpressionAttributeValues: {
      ':userId': { N: userId.toString() },
    },
    ScanIndexForward: false,
    Limit: PER_PAGE,
    ...(exclusiveStartKey ? { ExclusiveStartKey: exclusiveStartKey } : {}),
  });
  const result = await client.send(command);
  console.debug("res items", result.Items)
  let items = result.Items.map(parseTodo);
  return { todos: items, lastEvaluatedKey: result.LastEvaluatedKey };
}

export async function createTodo({ todo, userId }) {
  const id = Date.now();
  const createdAt = Date.now();
  const item = serializeTodo({ id, userId, createdAt, todo, done: false });
  const command = new PutItemCommand({
    TableName: 'todos2',
    Item: item,
  });
  await client.send(command);
  return { id, userId, createdAt, todo, done: false };
}

export async function getTodo({ id }) {
  const command = new GetItemCommand({
    TableName: 'todos2',
    Key: {
      id: { N: id.toString() },
    },
  });
  const result = await client.send(command);
  return result.Item ? parseTodo(result.Item) : null;
}
