import React, { useMemo, useState, useEffect } from "react";
import "./Reservation.css";
import logo from "../assets/logo.png";
import { Link } from "react-router-dom";

function Reservation() {
  const [date, setDate] = useState("");
  const [people, setPeople] = useState("");
  const [time, setTime] = useState("");
  const [status, setStatus] = useState("idle");
  const [availableTables, setAvailableTables] = useState([]);
  const [availableTimes, setAvailableTimes] = useState([]);
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

  const rawTimeSlots = useMemo(() => {
    if (!date) return [];
    const selected = new Date(`${date}T12:00:00`);
    const day = selected.getDay();
    const startMinutes = 17 * 60;
    const endMinutes = day === 0 ? 19 * 60 : 21 * 60;

    const slots = [];
    for (let mins = startMinutes; mins < endMinutes; mins += 15) {
      const hour = Math.floor(mins / 60);
      const minute = mins % 60;
      const value = `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}:00`;
      const end = mins + 15;
      const label = `${to12Hour(mins)} – ${to12Hour(end)}`;
      slots.push({ value, label });
    }
    return slots;
  }, [date]);

  const timeOptions = useMemo(() => {
    if (!date || availableTimes.length === 0) return [];
    return rawTimeSlots.filter((slot) => availableTimes.includes(slot.value));
  }, [date, rawTimeSlots, availableTimes]);

  const selectedTimeLabel = timeOptions.find((slot) => slot.value === time)?.label || "";
  const selectedPeopleLabel =
    people && Number(people) === 1 ? "1 guest" : people ? `${people} guests` : "";

  function isValidPhone(phone) {
    const digits = phone.replace(/\D/g, "");
    return digits.length >= 10;
  }

  useEffect(() => {
    const loadAvailableTimes = async () => {
      if (!date || !people) {
        setAvailableTimes([]);
        setTime("");
        setStatus("idle");
        return;
      }

      try {
        const response = await fetch("http://localhost:5001/api/find-available-times", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ date, people }),
        });

        const data = await response.json();

        if (!response.ok) {
          console.error("Error loading available times:", data.error);
          setAvailableTimes([]);
          return;
        }

        const times = data.available_times || [];
        setAvailableTimes(times);

        if (times.length === 0) {
          setStatus("noAvailability");
          setTime("");
        } else {
          if (status === "noAvailability") {
            setStatus("idle");
          }
        }
      } catch (error) {
        console.error("Error fetching available times:", error);
        setAvailableTimes([]);
      }
    };

    loadAvailableTimes();
  }, [date, people]);

  function handleResetSearch() {
    // Reset to search form, clear time, keep date and people
    setStatus("idle");
    setTime("");
    setAvailableTables([]);
    // Don't clear availableTimes - they'll be refetched when time dropdown opens
  }

  async function handleFindTable(e) {
    e.preventDefault();

    if (!date || !people || !time) {
      setStatus("noAvailability");
      return;
    }

    try {
      const response = await fetch("http://localhost:5001/api/find-available-tables", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ date, people, time }),
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

    try {
      const reservationData = {
        date,
        people,
        time,
        occasion: details.occasion,
        name: `${details.firstName} ${details.lastName}`,
        email: details.email,
        phone: details.phone,
        textUpdates: details.textUpdates,
      };

      const reservationResponse = await fetch("http://localhost:5001/api/reserve-table", {
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
                <span>
                  No tables available for {formatDisplayDate(date)}. Please choose another date.
                </span>
              </div>
            )}
            <form className="reservation-search-row" onSubmit={handleFindTable}>
              <div className="search-field">
                <label htmlFor="date">DATE</label>
                <div
                  className="custom-date-wrapper"
                  onClick={() => {
                    const input = document.getElementById("date");
                    if (input?.showPicker) {
                      input.showPicker();
                    } else {
                      input?.focus();
                    }
                  }}
                >
                  <span className={!date ? "placeholder-text" : ""}>
                    {date ? formatDisplayDate(date) : "Select a date"}
                  </span>
                </div>
                <input
                  id="date"
                  type="date"
                  value={date}
                  onChange={(e) => {
                    setDate(e.target.value);
                    setTime("");
                  }}
                  min={new Date().toISOString().split('T')[0]}
                  className="hidden-date-input"
                />
              </div>
              <div className="search-field select-field">
                <label htmlFor="people">PEOPLE</label>
                <select
                  id="people"
                  value={people}
                  onChange={(e) => setPeople(e.target.value)}
                  className={!people ? "placeholder-select" : ""}
                >
                  <option value="" disabled hidden>
                    Select number of guests
                  </option>
                  {peopleOptions.map((count) => (
                    <option key={count} value={count}>
                      {count} {count === 1 ? "guest" : "guests"}
                    </option>
                  ))}
                </select>
              </div>
              <div className="search-field select-field">
                <label htmlFor="time">TIME</label>
                <select
                  id="time"
                  value={time}
                  onChange={(e) => setTime(e.target.value)}
                  className={!time ? "placeholder-select" : ""}
                  disabled={!date || availableTimes.length === 0}
                >
                  <option value="" disabled hidden>
                    Select time
                  </option>
                  {timeOptions.map((slot) => (
                    <option key={slot.value} value={slot.value}>
                      {slot.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="search-button-wrap">
                <label className="search-button-label" aria-hidden="true">
                  spacer
                </label>
                <button
                  type="button"
                  className="find-table-btn"
                  disabled={!date || !time || !people}
                  onClick={handleFindTable}
                >
                  FIND A TABLE
                </button>
              </div>
            </form>
          </>
        )}
        {status === "found" && (
          <>
            <img src={logo} alt="Café Fausse logo" className="reservation-logo" />
            <h1 className="reservation-subtitle">RESERVATION</h1>
            <div className="reservation-summary-with-btn">
              <div className="reservation-summary">
                <div className="summary-item">📅 {formatDisplayDate(date)}</div>
                <div className="summary-item">👤 {selectedPeopleLabel}</div>
                <div className="summary-item">🕒 {selectedTimeLabel}</div>
              </div>
              
              {/* CHANGE DATE/TIME BUTTON */}
              <button
                type="button"
                className="change-reservation-btn"
                onClick={handleResetSearch}
              >
                NEW SEARCH
              </button>
            </div>

            
            <div className="dress-code-box">
              <p>
                <strong>Dress code:</strong> You will be asked to be dressed elegantly and
                correctly in the restaurant. Shorts, sportswear not accepted.
              </p>
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
            <div className="confirmed-name">
              {details.firstName} {details.lastName} – {details.email}
            </div>
            <div className="confirmed-message">
              A confirmation email has been sent to you. Please contact us with any
              modification.
            </div>
            
            {/* NEW RESERVATION LINK */}
            <Link to="/reservation" className="new-reservation-btn">
              ✦ Make a New Reservation
            </Link>
            
            <Link to="/" className="secondary-link-btn">
              GO HOME
            </Link>
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
                <input
                  id="firstName"
                  type="text"
                  name="firstName"
                  placeholder="Enter your name"
                  value={details.firstName}
                  onChange={handleDetailsChange}
                />
              </div>
              <div className="details-field">
                <label htmlFor="lastName">Last Name*</label>
                <input
                  id="lastName"
                  type="text"
                  name="lastName"
                  placeholder="Enter your name"
                  value={details.lastName}
                  onChange={handleDetailsChange}
                />
              </div>
            </div>
            <div className="details-field">
              <label htmlFor="email">E-mail*</label>
              <input
                id="email"
                type="email"
                name="email"
                placeholder="Enter your e-mail address"
                value={details.email}
                onChange={handleDetailsChange}
              />
            </div>
            <div className="details-field">
              <label htmlFor="phone">
                Phone number <span style={{ color: "#666" }}>(optional)</span>
              </label>
              <input
                id="phone"
                type="text"
                name="phone"
                placeholder="Enter your phone number"
                value={details.phone}
                onChange={handleDetailsChange}
              />
              {!isValidPhone(details.phone) && details.phone && (
                <small className="field-error">
                  Please enter a valid phone number (at least 10 digits)
                </small>
              )}
            </div>
            <div className="details-field">
              <label htmlFor="occasion">Occasion (optional)</label>
              <input
                id="occasion"
                type="text"
                name="occasion"
                placeholder="Enter your occasion"
                value={details.occasion}
                onChange={handleDetailsChange}
              />
            </div>
            <p className="mandatory-note">All fields with * are mandatory</p>
            <label className="checkbox-row">
              <input
                type="checkbox"
                name="newsletter"
                checked={details.newsletter}
                onChange={handleDetailsChange}
              />
              Please add me to your Newsletter
            </label>
            <label className="checkbox-label">
              <input
                type="checkbox"
                checked={details.textUpdates}
                onChange={handleDetailsChange}
                name="textUpdates"
                disabled={!isValidPhone(details.phone)}
              />
              <span>
                Yes, I want to get text updates and reminders about my reservation
              </span>
            </label>
            <button type="submit" className="complete-reservation-btn">
              Complete my reservation
            </button>
          </form>
        </section>
      )}
    </div>
  );
}

export default Reservation;
