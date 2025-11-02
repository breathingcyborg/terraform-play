import { seedTodos, getTodos, createTodo, getTodo } from './todos.mjs';

const corsHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const handlers = {

  'GET /todos': async (event) => {
    const { queryStringParameters } = event;
    const userId = parseInt(queryStringParameters?.userId);
    const exclusiveStartKey = queryStringParameters?.lastEvaluatedKey ? JSON.parse(queryStringParameters.lastEvaluatedKey) : undefined;

    if (!userId) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'userId query parameter required' }),
      };
    }

    const result = await getTodos({ userId, exclusiveStartKey });
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(result),
    };
  },

  'POST /todos': async (event) => {
    const { body } = event;
    const { todo, userId } = JSON.parse(body || '{}');

    if (!todo || !userId) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'todo and userId required in body' }),
      };
    }

    const result = await createTodo({ todo, userId });
    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify(result),
    };
  },

  'GET /todos/{id}': async (event) => {
    const { pathParameters } = event;
    const result = await getTodo({ id: pathParameters.id });
    if (!result) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Todo not found' }),
      };
    }
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(result),
    };
  },

  'OPTIONS /todos': async () => ({
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ message: 'CORS preflight' }),
  }),

  'OPTIONS /todos/{id}': async () => ({
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ message: 'CORS preflight' }),
  }),

  'POST /seed': async () => {
    await seedTodos();
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ message: 'Seeded todos successfully' }),
    };
  },
};

export const handler = async (event) => {
  console.debug(event);

  try {
    const handlerFunction = handlers[event.routeKey];
    if (!handlerFunction) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Route not found' }),
      };
    }
    return await handlerFunction(event);
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
};
