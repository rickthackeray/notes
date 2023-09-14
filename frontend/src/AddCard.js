import React, {useState} from "react"

import "./AddCard.css"

export default function AddCardForm(props) {
    const [formData, setFormData] = useState({
        title: "",
        description: ""
    })

    function handleSubmit (event) {
        event.preventDefault()
        props.addCard(formData)
        setFormData({
            title: "",
            description: ""
        })
    }

    function handleChange(event) {
        setFormData(prev => {
            return {
                ...prev,
                [event.target.name]: event.target.value
            }
        })
    }



    return (
        <div className="addcard">
            <form onSubmit={handleSubmit}>
                <input
                    type="text"
                    placeholder="Title"
                    onChange={handleChange}
                    className="title"
                    name="title"                
                    value={formData.title}
                />
                <input
                    type="text"
                    placeholder="Description"
                    onChange={handleChange}
                    className="description"
                    name="description"                
                    value={formData.description}
                />
                <button>
                    <svg className="submit" viewBox="0 0 24 24" role="img" xmlns="http://www.w3.org/2000/svg" aria-labelledby="returnIconTitle"  fill="none" color="#000000">
                        <title>Enter</title>
                        <path d="M19,8 L19,11 C19,12.1045695 18.1045695,13 17,13 L6,13"/>
                        <polyline points="8 16 5 13 8 10"/></svg>
                </button>
            </form>
        </div>
    )





}


