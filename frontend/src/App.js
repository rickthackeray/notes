import React, {useState, useEffect} from "react"

import './App.css';
import Card from "./Card"
import AddCard from "./AddCard"

function App() {
  const [cardData, setCardData] = useState([])

  const host = 'http://127.0.0.1:8000'

  useEffect(() => {
    loadCardData()
  },[])

  function loadCardData() {
    fetch(host + '/cards')
    .then(response => response.json())
    .then(data => {
      data = data.map(prev => {
        return {...prev}
      })
      setCardData(data)
    })
  }

  function deleteCard(id) {
    fetch(host + '/card?id=' + id, {method: 'DELETE'})
    .then(setCardData(prev => prev.filter(card => card._id !== id)))
  }


  function addCard(props) {
    fetch(host + '/card?title=' + props.title + '&description=' + props.description, {method: 'POST'})
    .then(response => response.json())
    .then(data => {
      console.log(data)
      setCardData(prev => [...prev, data])
    })
}

  const cards = cardData.map(card => {
    return <Card 
      key = {card._id}
      title = {card.title}
      description = {card.description}
      delete = {() => deleteCard(card._id)}
    />
  })


  return (
    <main className="main-container">
      <AddCard addCard={addCard}/>
      <div className="cards">{cards}</div>
    </main>
  )

}

export default App;
