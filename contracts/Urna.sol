// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "OpenZeppelin-Ownable/access/Ownable.sol";

contract Urna is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}
    
    event VotoRegistrado(uint idCandidato, string nombreCandidato);

    uint duracionJornada = 8 hours;
    uint limiteInscripciones = 1 days;

    struct Jornada {
        string nombre;
        uint256 fechaHoraInicio;
    }

    struct Partido {
        string nombre;
    }

    struct Candidato {
        string nombre;
        string partido;
        uint votos;
    }

    struct Participante {
        string nombre;
        bool haVotado;
    }

    Partido[] public partidos;
    Candidato[] public candidatos;
    Participante[] public participantes;
    Jornada public jornadaVotacion;

    mapping (address => uint) votoACandidato;
    mapping (address => uint) inscripcionParticipante;

    modifier mayorDeEdad(uint8 _edad) {
        require(_edad >= 18);
        _;
    }

    modifier dentroDePlazoInscripciones {
        require(block.timestamp <= (jornadaVotacion.fechaHoraInicio - limiteInscripciones));
        _;
    }

    modifier duranteJornada {
        require((block.timestamp >= jornadaVotacion.fechaHoraInicio) && (block.timestamp <= (jornadaVotacion.fechaHoraInicio + duracionJornada)));
        _;
    }

    modifier despuesDeJornada {
        require(block.timestamp >= (jornadaVotacion.fechaHoraInicio + duracionJornada));
        _;
    }

    function crearJornada(string memory _nombre, uint256 _fechaHoraInicio) public onlyOwner {
        require(jornadaVotacion.fechaHoraInicio == 0);
        jornadaVotacion.nombre = _nombre;
        jornadaVotacion.fechaHoraInicio = _fechaHoraInicio;
    }

    function _crearParticipante(string memory _nombre) internal {
        participantes.push(Participante(_nombre, false));

        inscripcionParticipante[msg.sender] = uint(participantes.length - 1);
    }

    function inscribirParticipante(string memory _nombre, uint8 _edad) public mayorDeEdad(_edad) dentroDePlazoInscripciones {
        require(inscripcionParticipante[msg.sender] == 0);

        _crearParticipante(_nombre);
    }

    function _crearCandidato(string memory _partido, string memory _nombre) internal {
        candidatos.push(Candidato(_nombre, _partido, 0));
    }

    function _crearPartido(string memory _partido, bool _partidoExiste) internal {
        require(!_partidoExiste);
        partidos.push(Partido(_partido));
    }

    function inscribirCandidato(string memory _partido, string memory _nombre) public onlyOwner dentroDePlazoInscripciones {
        bool partidoExiste = false;

        for (uint i = 0; i < partidos.length; i++) {
            if (keccak256(abi.encodePacked(partidos[i].nombre)) == keccak256(abi.encodePacked(_partido))) {
                partidoExiste = true;
            }
        }

        _crearPartido(_partido, partidoExiste);
        _crearCandidato(_partido, _nombre);
    }

    function verNumeroCandidatos() external view duranteJornada returns(uint) {
        return candidatos.length;
    }

    function verCandidato(uint _idCandidato) external view duranteJornada returns(string memory, string memory) {
        Candidato storage candidatoConsulta = candidatos[_idCandidato];
        return (candidatoConsulta.nombre, candidatoConsulta.partido);
    }

    function enviarVoto(uint _idCandidato) public duranteJornada {
        uint idParticipante = inscripcionParticipante[msg.sender];
        uint nuevoVoto = 0;

        if (!participantes[idParticipante].haVotado) {
            nuevoVoto = 1;
            votoACandidato[msg.sender] = _idCandidato;
            participantes[idParticipante].haVotado = true;
        }

        Candidato storage candidatoVoto = candidatos[ votoACandidato[msg.sender] ];
        candidatoVoto.votos = candidatoVoto.votos + nuevoVoto;

        emit VotoRegistrado(votoACandidato[msg.sender], candidatoVoto.nombre);
    }

    function verVoto() external view duranteJornada returns(uint) {
        return votoACandidato[msg.sender];
    }

    function verTotalVotos() external view despuesDeJornada returns(uint) {
        uint counter = 0;

        for (uint i = 0; i < candidatos.length; i++) {
            counter = counter + candidatos[i].votos;
        }

        return counter;
    }

    function verResultadoVotaciones() external view despuesDeJornada returns(Candidato[] memory) {
        return candidatos;
    }
}