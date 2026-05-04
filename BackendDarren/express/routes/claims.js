var express = require('express')
const db = require('../database/database')
var router = express.Router()

router.post('/', function(req,res){

    const {user_id, food_id} = req.body

    if(!user_id || !food_id){
        return res.status(400).send({message: "Incomplete Data"});
    }

    db.query(
        `INSERT INTO claims (user_id, food_id) VALUES (?, ?)`,[user_id, food_id],
        (err, result) => {
            if(err){
                console.log(err)
                return res.status(500).send({message: "error"})
            }
            return res.status(200).send({message: "Food taken"})
        }
    )
})

router.get('/:user_id', function(req,res){

    const userId = req.params.user_id;

    db.query(
        `SELECT foods.name, foods.location, claims.created_at
        FROM claims
        JOIN foods ON claims.food_id = foods.id
        WHERE claims.user_id = ?`,
        [userId],
        (err,result) => {
            if(err) {
                console.log(err)
                res.status(500).send({message: "error"})
            }
            return res.status(200).send(result)
        }
    )
})

module.exports = router