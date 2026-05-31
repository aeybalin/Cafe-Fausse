import React, { useMemo, useState } from "react";
import "./Reservation.css";
import logo from "../assets/logo.png";
import { Link } from "react-router-dom";

function Reservation() {
  const [date, setDate] = useState("");
  const [people, setPeople] = useState("");
  const [time, setTime] = useState("");
  const [status, setStatus] = useState("idle");
  const [availableTables, setAvailableTables] = useState([]);
  const [details, setDetails] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    occasion: "",
    newsletter: false,
    textUpdates: false,
  });

  const peopleOptions = Array.from({ length: 12 }, (_, i) => i + 1);

  function formatDisplayDate(dateStr) {
    if (!dateStr) return "";
    const selected = new Date(`${dateStr}T12:00:00`);
    return selected.toLocaleDateString("en-US", {
      weekday: "short",
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  }

  function to12Hour(minutes) {
    const hrs24 = Math.floor(minutes / 60);
    const mins = minutes % 60;
    const suffix = hrs24 >= 12 ? "PM" : "AM";
    const hrs12 = hrs24 % 12 === 0 ? 12 : hrs24 % 12;
    return `${hrs12}:${String(mins).padStart(2, "0")} ${suffix}`;
  }

  const timeOptions = useMemo(() => {
    if (!date) return [];
    const selected = new Date(`${date}T12:00:00`);
    const day = selected.getDay();
    const startMinutes = 17 * 60;
    const endMinutes = day === 0 ? 19 * 60 : 21 * 60;
    const slots = [];
    for (let mins = startMinutes; mins <= endMinutes; mins += 15) {
      const end = mins + 15;
      slots.push({
        value: `${String(Math.floor(mins / 60)).padStart(2, "0")}:${String(mins % 60).padStart(2, "0")}:00`,
        label: `${to12Hour(mins)} – ${to12Hour(end)}`,
      });
    }
    return slots;
  }, [date]);

  const selectedTimeLabel = timeOptions.find((slot) => slot.value === time)?.label || "";
  const selectedPeopleLabel = people && Number(people) === 1 ? "1 guest" : people ? `${people} guests` : "";

async function handleFindTable(e) {
  e.preventDefault();
  
  if (!date || !people || !time) {
    setStatus("noAvailability");
    return;
  }

  try {
    const response = await fetch("http://localhost:5001/api/find-available-tables", {
      method: "POST",
      headers: { 
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        date: date,
        people: people,
        time: time 
      })
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || "Failed to find tables");
    }
    if (!data.available || data.tables.length === 0) {
      setStatus("noAvailability");
      return;
    }
    setAvailableTables(data.tables);
    setStatus("found");
  } catch (error) {
    console.error("Error finding tables:", error);
    setStatus("noAvailability");
  }
}
  function handleDetailsChange(e) {
    const { name, value, type, checked } = e.target;
    setDetails((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  }

  async function handleCompleteReservation(e) {
    e.preventDefault();
    if (!details.firstName || !details.lastName || !details.email) {
      return;
    }
    try {
      const formData = new FormData();
      formData.append("firstName", details.firstName);
      formData.append("lastName", details.lastName);
      formData.append("email", details.email);
      formData.append("phone", details.phone || "");
      formData.append("occasion", details.occasion || "");
      formData.append("newsletter", details.newsletter);
      formData.append("textUpdates", details.textUpdates);
      const customerResponse = await fetch("http://localhost:5001/api/get-or-create-customer", {
        method: "POST",
        body: formData,
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });
      const customerData = await customerResponse.json();
      if (!customerResponse.ok) {
        throw new Error(customerData.error || "Failed to create customer");
      }
      const customerId = customerData.customer_id;
      const reservationData = {
        customer_id: customerId,
        date: date,
        time: time,
        party_size: parseInt(people),
      };
      const reservationResponse = await fetch("http://localhost:5001/api/create-reservation-auto", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(reservationData),
      });
      const reservationResult = await reservationResponse.json();
      if (!reservationResponse.ok || !reservationResult.success) {
        throw new Error(reservationResult.error || "Failed to create reservation");
      }
      setStatus("confirmed");
    } catch (error) {
      console.error("Error creating reservation:", error);
      alert("Failed to create reservation. Please try again.");
    }
  }

  return (
    <div className="reservation-page">
      <section className="reservation-card">
        {(status === "idle" || status === "noAvailability") && (
          <>
            <h1 className="reservation-title">MAKE A RESERVATION</h1>
            {status === "noAvailability" && (
              <div className="reservation-alert error-alert">
                <span className="alert-icon">⚠</span>
                <span>At the moment, there's no online availability within 2.5 hours of {formatDisplayDate(date)} {selectedTimeLabel}</span>
              </div>
            )}
            <form className="reservation-search-row" onSubmit={handleFindTable}>
              <div className="search-field">
                <label htmlFor="date">DATE</label>
                <div className="custom-date-wrapper" onClick={() => {
                  const input = document.getElementById("date");
                  if (input?.showPicker) { input.showPicker(); } else { input?.focus(); }
                }}>
                  <span className={!date ? "placeholder-text" : ""}>{date ? formatDisplayDate(date) : "Select a date"}</span>
                </div>
                <input id="date" type="date" value={date} onChange={(e) => { setDate(e.target.value); setTime(""); }} className="hidden-date-input" />
              </div>
              <div className="search-field select-field">
                <label htmlFor="people">PEOPLE</label>
                <select id="people" value={people} onChange={(e) => setPeople(e.target.value)} className={!people ? "placeholder-select" : ""}>
                  <option value="" disabled hidden>Select number of guests</option>
                  {peopleOptions.map((count) => (
                    <option key={count} value={count}>{count} {count === 1 ? "guest" : "guests"}</option>
                  ))}
                </select>
              </div>
              <div className="search-field select-field">
                <label htmlFor="time">TIME</label>
                <select id="time" value={time} onChange={(e) => setTime(e.target.value)} className={!time ? "placeholder-select" : ""} disabled={!date}>
                  <option value="" disabled hidden>Select time</option>
                  {timeOptions.map((slot) => (
                    <option key={slot.value} value={slot.value}>{slot.label}</option>
                  ))}
                </select>
              </div>
              <div className="search-button-wrap">
                <label className="search-button-label" aria-hidden="true">spacer</label>
                <button type="submit" className="find-table-btn">FIND A TABLE</button>
              </div>
            </form>
          </>
        )}
        {status === "found" && (
          <>
            <img src={logo} alt="Café Fausse logo" className="reservation-logo" />
            <h1 className="reservation-subtitle">RESERVATION</h1>
            <div className="reservation-summary">
              <div className="summary-item">📅 {formatDisplayDate(date)}</div>
              <div className="summary-item">👤 {selectedPeopleLabel}</div>
              <div className="summary-item">🕒 {selectedTimeLabel}</div>
            </div>
            <div className="dress-code-box">
              <p><strong>Dress code:</strong> You will be asked to be dressed elegantly and correctly in the restaurant. Shorts, sportswear not accepted.</p>
            </div>
          </>
        )}
        {status === "confirmed" && (
          <>
            <h1 className="reservation-title">RESERVATION CONFIRMED</h1>
            <div className="reservation-alert success-alert">
              <span className="alert-icon">✓</span>
              <span>Success! Your reservation is confirmed</span>
            </div>
            <div className="reservation-summary">
              <div className="summary-item">📅 {formatDisplayDate(date)}</div>
              <div className="summary-item">👤 {selectedPeopleLabel}</div>
              <div className="summary-item">🕒 {selectedTimeLabel}</div>
            </div>
            <div className="confirmed-name">{details.firstName} {details.lastName} – {details.email}</div>
            <div className="confirmed-message">A confirmation email has been sent to you. Please contact us with any modification.</div>
            <Link to="/" className="secondary-link-btn">GO HOME</Link>
          </>
        )}
      </section>
      {status === "found" && (
        <section className="reservation-details-section">
          <h2 className="details-heading">RESERVATION DETAILS</h2>
          <form className="details-form" onSubmit={handleCompleteReservation}>
            <div className="two-column-row">
              <div className="details-field">
                <label htmlFor="firstName">First Name*</label>
                <input id="firstName" type="text" name="firstName" placeholder="Enter your name" value={details.firstName} onChange={handleDetailsChange} />
              </div>
              <div className="details-field">
                <label htmlFor="lastName">Last Name*</label>
                <input id="lastName" type="text" name="lastName" placeholder="Enter your name" value={details.lastName} onChange={handleDetailsChange} />
              </div>
            </div>
            <div className="details-field">
              <label htmlFor="email">E-mail*</label>
              <input id="email" type="email" name="email" placeholder="Enter your e-mail address" value={details.email} onChange={handleDetailsChange} />
            </div>
            <div className="details-field">
              <label htmlFor="phone">Phone number (optional)</label>
              <input id="phone" type="text" name="phone" placeholder="Enter your phone number" value={details.phone} onChange={handleDetailsChange} />
            </div>
            <div className="details-field">
              <label htmlFor="occasion">Occasion (optional)</label>
              <input id="occasion" type="text" name="occasion" placeholder="Enter your occasion" value={details.occasion} onChange={handleDetailsChange} />
            </div>
            <p className="mandatory-note">All fields with * are mandatory</p>
            <label className="checkbox-row">
              <input type="checkbox" name="newsletter" checked={details.newsletter} onChange={handleDetailsChange} />
              Please add me to your Newsletter
            </label>
            <label className="checkbox-row">
              <input type="checkbox" name="textUpdates" checked={details.textUpdates} onChange={handleDetailsChange} />
              Yes, I want to get text updates and reminders about my reservation
            </label>
            <button type="submit" className="complete-reservation-btn">Complete my reservation</button>
          </form>
        </section>
      )}
    </div>
  );
}

export default Reservation;
