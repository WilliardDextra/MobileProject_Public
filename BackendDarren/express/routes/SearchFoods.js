var express = require('express');
const db = require('../database/database');
var router = express.Router()

//Search Food
router.get('/search', function(req,res){

    const keyword = req.query.q;

    //Validation Input Keyword
    if(!keyword || keyword.trim() === '') {
        return res.status(400).send({message: "Keyword is required"})
    }

    db.query(
        `SELECT * FROM foods
        WHERE LOWER(name) LIKE LOWER(?) AND status = "available"`,
        [`%${keyword}%`],
        (err,result) => {
            if(err){
                console.log(err)
                return res.status(500).send({message: "error"})
            }
            return res.status(200).send(result)
        }
    )
})

//Get All Available Foods
router.get('/', function(req,res){
    
    db.query(
        `SELECT * FROM foods WHERE status = "available"`,
        (err,result) => {
            if(err){
                console.log(err)
                return res.status(500).send({message: "error"})
            }
            return res.status(200).send(result)
        }
    )
})

module.exports = router;