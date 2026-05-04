var express = require('express');
const db = require('../database/database');
var router = express.Router();

//GET users DATA
/*router.get('/', function(req, res, next) {
  db.query(
    `SELECT * FROM users`,
    (err,result) => {
      if(err) return res.status(501).send({message: "error get data"})
        return res.status(200).send(result)
    }
  )
});*/

//GET DATA USER WITH SPESIFIC ID
router.get('/:id', function(req,res){
  const userId = req.params.id;

  db.query(
    `SELECT id, name, email FROM users WHERE id = ?`,
    [userId],
    (err,result) => {
      if(err){
        console.log(err)
        return res.status(500).send({message: "error get profile"})
      }

      if(result.length === 0){
        return res.status(404).send({message: "user not found"})
      }

      return res.status(200).send(result[0])
    }
  )
})

//UPDATE PROFILE USER WITH SPESIFIC ID
router.put('/:id', function(req,res){
  const userId = req.params.id
  const {name,email} = req.body

  if( !name || !email ){
    return res.status(400).send({message: "Incomplete data"})
  }

  db.query(
    `UPDATE users SET name = ?, email = ? WHERE id = ?`,
    [name,email,userId],
    (err,result) => {
      if(err){
        console.log(err)
        return res.status(500).send({message: "Error update profile"})
      }

      if(result.affectedRows === 0){
        return res.status(404).send({message: "User not found"})
      }

      return res.status(200).send({message: "Sucessfully updated"})
    } 
  )
})

//UPDATE PASSWORD
router.put('/:id/password', function(req,res){
  const userId = req.params.id
  const {oldPassword, newPassword} = req.body

  if( !oldPassword || !newPassword ) {
    return res.status(400).send({message: "Incomplete data"})
  }

  db.query(
    `SELECT password FROM users WHERE id = ?`,
    [userId],
    (err,result) => {
      if(err) {
        return res.status(500).send({message: "error"})
      }

      if(result.length === 0){
        return res.status(404).send({message: "User not found"})
      }

      const currPassword = result[0].password

      if(oldPassword !== currPassword){
        return res.status(401).send({message: "Invalid password"})
      }

      //UPDATE PASSWORD BARU
      db.query(
        `UPDATE users SET password = ? WHERE id = ?`, [newPassword,userId],
        (err2) => {
          if(err2) return res.status(500).send(err2);

          return res.status(200).send({message: "Password changed"})
        }
      )
    }
  )
})


module.exports = router;
