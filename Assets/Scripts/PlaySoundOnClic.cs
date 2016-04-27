using UnityEngine;
using System.Collections;

public class PlaySoundOnClic : MonoBehaviour {

	public AudioClip[] sounds;
	[Range(0, 1)] public float ChanceOfRotation = 0.4f;
	public ParticleSystem noteParticleSystem;


	private AudioSource audioSource;
	private SpriteRenderer spriteRenderer;
	private Animator animator;
	private SpriteOutline spriteOutline;




	void Start () {
		// get a reference of all the needed components
		audioSource = GetComponent<AudioSource>();
		spriteRenderer = GetComponent<SpriteRenderer>();
		animator = GetComponent<Animator>();
		spriteOutline = GetComponent<SpriteOutline>();
	}


	void Update () {

		// if player press Space
		if (Input.GetKeyDown("space")) {

			// pick a random sound between all the given sounds
			AudioClip chosenSound = sounds[Random.Range(0, sounds.Length)];
			// and play it
			audioSource.PlayOneShot(chosenSound,1);

			// emit one note from the particle system
			noteParticleSystem.Emit(1);


			// set a random outline color
			spriteOutline.color =  new Color(Random.value, Random.value, Random.value, 1);

			// play the bounce animation
			animator.SetTrigger("Bounce");

			// and maybe flip the bird horizontaly
			if (Random.value < ChanceOfRotation) {
				spriteRenderer.flipX = !spriteRenderer.flipX;
			}
		}
	}
}
