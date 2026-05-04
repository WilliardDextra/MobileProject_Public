var express = require('express')
const db = require('../database/database')
var router = express.Router()

//Create Order (checkout/reorder)
router.post('/', function(req,res){
    const {user_id,food_id,quantity} = req.body

    if(!user_id || !food_id || !quantity){
        return res.status(400).send({message: "Incomplete data"})
    }

    db.query(
        `INSERT INTO orders (user_id, food_id, quantity, status, purchase_date)
         VALUES (?, ?, ?, 'Completed', NOW())`,
        [user_id, food_id, quantity],
        (err,result) => {
            if(err){
                console.log(err)
                return res.status(501).send({message: "Error"})
            }

            return res.status(200).send({message: "Order created"})
        }
    )
})


//Get Order History --> cart.dart
router.get('/:user_id', function(req,res){
    const userId = req.params.user_id

    if(!userId){
        return res.status(400).send({message: "User ID required"})
    }

    db.query(
        `
        SELECT 
            f.name,
            f.description,
            o.quantity,
            f.location,
            o.status,
            o.purchase_date,
            f.image,
            f.rating,
            f.price
        FROM orders o
        JOIN foods f ON o.food_id = f.id
        WHERE o.user_id = ?
        ORDER BY o.purchase_date DESC
        `,
        [userId],
        (err,result) => {
            if(err){
                return res.status(500).send({message: "Error"})
            }

            return res.status(200).send(result)
        }
    )
})

module.exports = router