export const handler = async (event) => {
  const auth = event.authorizationToken || event.headers.authorization;
  console.log('Auth event:', JSON.stringify(event, null, 2));
  
  if (!auth || !auth.startsWith('Bearer ')) {
    console.log('No Bearer token');
    return denyResponse();
  }
  
  const userIdStr = auth.slice(7);
  console.log('User ID string:', userIdStr);
  
  const userId = parseInt(userIdStr);
  if (!userId || userId <= 0) {
    console.log('Invalid user ID');
    return denyResponse();
  }
  
  console.log('Allowing user:', userId);
  return allowResponse(userId);
};

function allowResponse(userId) {
  return {
    isAuthorized: true,
    context: { userId }
  };
}

function denyResponse() {
  return {
    isAuthorized: false
  };
}