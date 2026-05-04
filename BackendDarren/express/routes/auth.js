var express = require('express');
const db = require('../database/database');
var router = express.Router();
const bcrypt = require('bcrypt');

//REGISTER
router.post('/register', function(req,res){

    const {name, email, password} = req.body

    //Input Validation
    if(!name || !email || !password){
       return res.status(400).send({message: "All fields are required"})
    }

    if(password.length < 6) {
        return res.status(400).send({message: "Password must be at least 6 character"})
    }

    //Check if email already exist
    db.query(
        `SELECT * FROM users WHERE email = ?`, [email],
        (err,result) => {
            if(err) return res.status(500).send({message: "Error checking email"});

            if(result.length > 0) {
                return res.status(400).send({message: "Email is already registered"});
            }

            //Hash password
            bcrypt.hash(password, 10, (err, hashedPassword) => {
                if(err) return res.status(500).send({message: "Error hashing password"});

                //Insert User
                db.query(
                    `INSERT INTO users (name, email, password) VALUES (?,?,?)`,
                    [name, email, hashedPassword],
                    (err2, result2) => {
                        if(err2){
                            console.log(err2)
                            return res.status(500).send({message: "Error inserting user"})
                        }

                        return res.status(201).send({
                            message: "Registration successful",
                            userId: result2.insertId
                        })
                    }
                )
            })
        }
    )
});

//LOGIN
router.post('/login', function(req, res){

  const {email, password} = req.body

  //Input Validation
  if(!email || !password){
    return res.status(400).send({message: "Email and password are required"});
  }

  //Find User by Email
  db.query(
    `SELECT * FROM users WHERE email = ?`,
    [email],
    (err,result) => {
        if(err){
            console.log(err)
            return res.status(500).send({message: "Server error"});
        }

        if(result.length === 0){
            return res.status(401).send({message: "Wrong email or password"});
        }

        const user = result[0]

        //Compare password
        bcrypt.compare(password, user.password, (err, isMatch) => {
            if(err) return res.status(500).send({message: "Error comparing password"});

            if(!isMatch){
                return res.status(401).send({message: "Wrong email or password"});
            }

            return res.status(200).send({
                message: "Login successful",
                userId: user.id
            })
        })
    })
})

module.exports = router;