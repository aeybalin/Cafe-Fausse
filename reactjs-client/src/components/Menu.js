import React from "react";
import "./Menu.css";
import logo from "../assets/logo.png";
import menuData from "../data/menu.json";

function Menu() {
  // Pull the menu object from the JSON file
  const categories = menuData.menu;

  // Keep notes in an array so they are easy to edit later too
  const notes = [
    "Our menu is seasonally updated",
    "Our staff is here to help you and can provide some pairing suggestions"
  ];

  return (
    <div className="menu-page">
      {/* =====================================================
          LOGO
      ====================================================== */}
      <div className="menu-logo-container">
        <img src={logo} alt="Café Fausse logo" className="menu-logo" />
    </div>

      {/* =====================================================
          MAIN MENU CARD
      ====================================================== */}
      <div className="menu-card">
        <h2 className="menu-title">MENU</h2>

        {/* Render each category from JSON */}
        {Object.entries(categories).map(([categoryName, items]) => (
          <div key={categoryName}>
            <h3 className="menu-category">{categoryName}:</h3>

            {items.map((item) => (
              <MenuItem
                key={`${categoryName}-${item.name}`}
                name={item.name}
                description={item.description}
                price={item.price}
              />
            ))}
          </div>
        ))}
      </div>

      {/* =====================================================
          NOTES SECTION
      ====================================================== */}
      <div className="menu-notes">
        <ul>
          {notes.map((note, index) => (
            <li key={index}>{note}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

/* =========================================================
   REUSABLE MENU ITEM COMPONENT
========================================================= */
function MenuItem({ name, description, price }) {
  return (
    <div className="menu-item">
      <div className="menu-item-header">
        <span className="item-name">{name}</span>
        <span className="dots"></span>
        <span className="price">${Number(price).toFixed(2)}</span>
      </div>
      <p>{description}</p>
    </div>
  );
}

export default Menu;