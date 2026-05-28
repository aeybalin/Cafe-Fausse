import { NavLink } from "react-router-dom";
import "./Navbar.css";
import logo from "../assets/logo.png";

function Navbar() {
  return (
    <div className="navbar">

      {/* LOGO LEFT */}
      <div className="logo-container">
        <NavLink to="/">
          <img src={logo} alt="Café Fausse Logo" className="logo-img" />
        </NavLink>
      </div>

      {/* CENTER MENU */}
      <div className="nav-links">

        <NavLink
          to="/"
          end
          className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}
        >
          Home
        </NavLink>

        <NavLink
          to="/menu"
          className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}
        >
          Menu
        </NavLink>

        <NavLink
          to="/reservation"
          className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}
        >
          Reservations
        </NavLink>

        <NavLink
          to="/about"
          className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}
        >
          About Us
        </NavLink>

        <NavLink
          to="/gallery"
          className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}
        >
          Gallery
        </NavLink>

      </div>

    </div>
  );
}

export default Navbar;
