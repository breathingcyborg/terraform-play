import express from 'express';

const app = express();

app.get("/", (req, res, next) => {
    // Crash intentionally if crash is true
    if (process.env.CRASH === "true") {
        res.status(500).json({ message: 'Crash' }).send();
        return
    }
    const time = new Date().toISOString();
    res.json({ 
        greetings: "hello world" ,
        time: time
    })
})

app.listen(3000, () => {
    console.debug(`Listening on port 3000`)
})