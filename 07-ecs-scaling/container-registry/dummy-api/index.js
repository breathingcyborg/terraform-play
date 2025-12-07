import express from 'express';

const app = express();

app.get("/", (req, res, next) => {
    const time = new Date().toISOString();
    res.json({ 
        greetings: "hello world" ,
        time: time
    })
})

app.listen(3000, () => {
    console.debug(`Listening on port 3000`)
})